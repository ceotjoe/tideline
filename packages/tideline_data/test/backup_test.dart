import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

const _codec = BackupCodec();

void main() {
  group('BackupCodec', () {
    test('round-trips', () {
      final data = List<int>.generate(5000, (i) => i % 7);
      expect(_codec.decode(_codec.encode(data)), data);
    });

    test('starts with the plain version-2 marker', () {
      final file = _codec.encode(utf8.encode('{"a":1}'));
      expect(String.fromCharCodes(file.sublist(0, 18)), 'TIDELINE-BACKUP 2\n');
    });

    test('damage is reported as a format error', () {
      final file = _codec.encode(List.filled(1000, 1));
      final damaged = Uint8List.fromList(file)..[file.length - 6] ^= 1;
      expect(
        () => _codec.decode(damaged),
        throwsA(isA<BackupFormatException>()),
      );
      expect(
        () => _codec.decode(file.sublist(0, file.length - 10)),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects foreign files', () {
      expect(
        () => _codec.decode('hello'.codeUnits),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('recognises an encrypted backup of 0.5.x', () {
      expect(
        () => _codec.decode('TIDELINE-BACKUP 1\n{}\n'.codeUnits),
        throwsA(isA<BackupEncryptedException>()),
      );
    });

    test('caps the decompressed size (zip bomb)', () {
      const small = BackupCodec(maxPayloadBytes: 1000);
      final bomb = _codec.encode(List.filled(100000, 0));
      expect(() => small.decode(bomb), throwsA(isA<BackupFormatException>()));
    });
  });

  group('BackupService', () {
    test('restores everything except tokens, without duplicates', () async {
      // Source device.
      final db = await openTestDatabase();
      final secrets = MemorySecretStore();
      final qsos = QsoRepository(
        db,
        HlcClock('a'),
        SyncMachine(random: Random(1)),
      );
      final accounts = AccountRepository(db, secrets);
      final accountId = await accounts.add(
        label: 'Home',
        baseUrl: 'https://log.example.org',
        usesIndexPhp: true,
        token: 'wl2_secret_token',
        scopes: {'qso:read', 'qso:write', 'station:read'},
        hasContestSessions: true,
        nowMillis: 0,
      );
      await accounts.syncStations(accountId, [
        (
          remoteId: 3,
          name: 'Home',
          callsign: 'DO1HOZ',
          grid: 'JO40',
          active: true,
        ),
      ], nowMillis: 0);
      final station = (await accounts.watchStations(accountId).first).single;
      Qso qso(String call, int minute) => Qso(
        id: newUuidV4(),
        accountId: accountId,
        stationProfileId: station.id,
        call: Callsign.tryParse(call)!,
        timeOn: UtcDateTime(DateTime.utc(2026, 10, 2, 14, minute)),
        band: Band.tryParse('40m')!,
        mode: Mode.tryParse('CW')!,
        freqHz: 7030500,
        fields: const {'NAME': 'Jörg', 'APP_X_Y': 'z'},
      );
      final synced = qso('DL1ABC', 1);
      final waiting = qso('G4XYZ', 2);
      await qsos.log(synced);
      await qsos.writeStatus(
        synced.id,
        accountId,
        const SyncStatus(state: SyncState.synced, remoteQsoId: 77),
      );
      await qsos.log(waiting);
      final notes = CallsignNoteRepository(db, HlcClock('a'));
      await notes.save('DL1ABC', 'Calls on 40 m');
      await notes.save('G4XYZ', 'Gone');
      await notes.delete('G4XYZ');
      final file = await BackupService(db, qsos).create(nowMillis: 1);
      expect(String.fromCharCodes(file), isNot(contains('wl2_secret_token')));

      // New device.
      final db2 = await openTestDatabase();
      final qsos2 = QsoRepository(
        db2,
        HlcClock('b'),
        SyncMachine(random: Random(1)),
      );
      final service2 = BackupService(db2, qsos2);
      final report = await service2.restore(file, nowMillis: 2);
      expect((report.accountsAdded, report.qsosAdded), (1, 2));
      // Notes come back; a deleted one does not, and its text is not in the
      // file.
      expect(report.notesAdded, 1);
      final notes2 = CallsignNoteRepository(db2, HlcClock('b'));
      expect(await notes2.find('DL1ABC'), 'Calls on 40 m');
      expect(await notes2.find('G4XYZ'), isNull);

      final restored = await qsos2.find(synced.id);
      expect(restored!.status!.remoteQsoId, 77); // never uploaded again
      expect(restored.qso.field('NAME'), 'Jörg');
      expect(restored.qso.field('APP_X_Y'), 'z');
      expect(restored.qso.freqHz, 7030500);
      expect((await qsos2.find(waiting.id))!.status!.state, SyncState.queued);
      // No token was restored: the account must be reconnected.
      expect(
        await AccountRepository(db2, MemorySecretStore()).tokenFor(accountId),
        isNull,
      );

      // Restoring again adds nothing.
      final again = await service2.restore(file, nowMillis: 3);
      expect((again.qsosAdded, again.qsosSkipped), (0, 2));
      expect(again.notesAdded, 0);

      // A note typed on the new device is not overwritten by a restore.
      await notes2.save('DL1ABC', 'newer');
      await service2.restore(file, nowMillis: 4);
      expect(await notes2.find('DL1ABC'), 'newer');
    });
  });
}
