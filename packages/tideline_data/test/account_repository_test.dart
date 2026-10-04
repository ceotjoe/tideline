import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/contest_fixtures.dart';
import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

void main() {
  late ContestHarness h;
  late MemorySecretStore secrets;
  late AccountRepository accounts;

  setUp(() async {
    h = await ContestHarness.create(await openTestDatabase());
    secrets = MemorySecretStore();
    accounts = AccountRepository(h.db, secrets);
  });

  Future<String> addOther(String label) => accounts.add(
    label: label,
    baseUrl: 'https://other.example.org',
    usesIndexPhp: true,
    token: 'secret-$label',
    scopes: {'qso:write'},
    hasContestSessions: false,
    nowMillis: 10,
  );

  Future<int> count(String table, [String? accountId]) async {
    final where = accountId == null ? '' : " WHERE account_id = '$accountId'";
    final rows = await h.db
        .customSelect('SELECT COUNT(*) AS n FROM $table$where')
        .get();
    return rows.single.read<int>('n');
  }

  test('rename changes only the label', () async {
    await accounts.rename('acc', '  Club station ');
    final a = (await accounts.find('acc'))!;
    expect(a.label, 'Club station');
    expect(a.baseUrl, 'https://log.example.org');
  });

  test('rename refuses an empty name', () async {
    expect(() => accounts.rename('acc', '   '), throwsArgumentError);
    expect((await accounts.find('acc'))!.label, 'Home');
  });

  test('remove tells the streams', () async {
    await addOther('Second');
    final seen = expectLater(
      accounts.watchAll().map((l) => l.map((a) => a.id).toList()),
      emitsInOrder([
        containsAll(['acc']),
        isNot(contains('acc')),
      ]),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await accounts.remove('acc');
    await seen;
  });

  test('remove deletes everything of the account and its token', () async {
    final other = await addOther('Second');
    // Everything that can reference the account: QSOs in a contest session
    // (with links and serials), an activation, the worked-before index.
    final session = await h.startSerial();
    final logged = await h.sessions.logContestQso(
      testQso(),
      sessionId: session.id,
    );
    await h.sessions.recordLinks(session.id, {logged.qso.id: 1});
    await h.db.customStatement(
      'INSERT INTO activations (id, account_id, program, reference, '
      'started_at, origin_device_id, hlc_created, hlc_modified) '
      "VALUES ('act', 'acc', 'pota', 'DL-0001', 1, 'dev', 'h', 'h')",
    );
    await h.qsos.log(testQso());
    await h.qsos.log(testQso(call: 'DL9XYZ', fields: {'NAME': 'Anna'}));
    await WorkedBeforeRepository(h.db).rebuildLocal('acc');
    // The other account keeps its data.
    await h.db.customStatement(
      'INSERT INTO worked_before (account_id, call, band, mode, first_time, '
      "source) VALUES ('$other', 'W1AW', '20m', 'CW', 1, 'local')",
    );
    secrets.values[SecretKeys.accountToken('acc')] = 'tok';

    await accounts.remove('acc');

    expect(await accounts.find('acc'), isNull);
    expect(await secrets.read(SecretKeys.accountToken('acc')), isNull);
    for (final table in [
      'qsos',
      'qso_sync',
      'sync_journal',
      'station_profiles',
      'contest_sessions',
      'activations',
      'worked_before',
      'callsign_directory',
    ]) {
      expect(await count(table, 'acc'), 0, reason: table);
    }
    expect(await count('contest_links'), 0);
    expect(await count('serial_allocations'), 0);
    expect(await count('worked_before', other), 1);
    expect(await accounts.find(other), isNotNull);
    expect(await secrets.read(SecretKeys.accountToken(other)), 'secret-Second');
  });
}
