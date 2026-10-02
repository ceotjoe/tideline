import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

// Small KDF parameters keep the tests fast; production uses the defaults.
const _codec = BackupCodec(memoryKiB: 1024, iterations: 1);

void main() {
  group('BackupCodec', () {
    test('round-trips and hides the content', () async {
      final data = List<int>.generate(5000, (i) => i % 7);
      final file = await _codec.encrypt(data, 'correct horse');
      expect(await _codec.decrypt(file, 'correct horse'), data);
      expect(String.fromCharCodes(file), isNot(contains('\x00\x01\x02\x03')));
    });

    test('a wrong passphrase is reported as such', () async {
      final file = await _codec.encrypt([1, 2, 3], 'right');
      await expectLater(
        _codec.decrypt(file, 'wrong'),
        throwsA(isA<BackupPassphraseException>()),
      );
    });

    test('tampering is detected (header and body are authenticated)', () async {
      final file = await _codec.encrypt([1, 2, 3], 'pw');
      final body = Uint8List.fromList(file)..[file.length - 20] ^= 1;
      await expectLater(
        _codec.decrypt(body, 'pw'),
        throwsA(isA<BackupPassphraseException>()),
      );
      final text = String.fromCharCodes(file);
      final header = Uint8List.fromList(
        text.replaceFirst('"t":1', '"t":2').codeUnits,
      );
      await expectLater(
        _codec.decrypt(header, 'pw'),
        throwsA(isA<BackupPassphraseException>()),
      );
    });

    test('rejects foreign files and hostile parameters', () async {
      await expectLater(
        _codec.decrypt('hello'.codeUnits, 'pw'),
        throwsA(isA<BackupFormatException>()),
      );
      const header = {
        'kdf': 'argon2id',
        'm': 99999999,
        't': 1,
        'p': 1,
        'salt': 'AAAAAAAAAAAAAAAAAAAAAA==',
        'cipher': 'xchacha20-poly1305',
        'nonce': 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
      };
      final hostile = 'TIDELINE-BACKUP 1\n${jsonEncode(header)}\n'.codeUnits;
      await expectLater(
        _codec.decrypt([...hostile, ...List.filled(32, 0)], 'pw'),
        throwsA(isA<BackupFormatException>()),
      );
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
      final file = await BackupService(
        db,
        qsos,
        codec: _codec,
      ).create('pw', nowMillis: 1);
      expect(String.fromCharCodes(file), isNot(contains('wl2_secret_token')));

      // New device.
      final db2 = await openTestDatabase();
      final qsos2 = QsoRepository(
        db2,
        HlcClock('b'),
        SyncMachine(random: Random(1)),
      );
      final service2 = BackupService(db2, qsos2, codec: _codec);
      final report = await service2.restore(file, 'pw', nowMillis: 2);
      expect((report.accountsAdded, report.qsosAdded), (1, 2));

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
      final again = await service2.restore(file, 'pw', nowMillis: 3);
      expect((again.qsosAdded, again.qsosSkipped), (0, 2));
    });
  });
}
