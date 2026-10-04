import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/test_database.dart';

void main() {
  test('counts every QSO that is not synced', () async {
    final db = await openTestDatabase();
    const hlc = '000000000000000-0000-dev';
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'acc',
            label: 'Home',
            baseUrl: 'https://log.example.org',
            createdAt: 0,
          ),
        );
    for (final (i, state) in SyncState.values.indexed) {
      await db
          .into(db.qsos)
          .insert(
            QsosCompanion.insert(
              id: 'q$i',
              accountId: 'acc',
              call: 'DL$i',
              timeOn: i,
              band: '20m',
              mode: 'CW',
              originDeviceId: 'dev',
              hlcCreated: hlc,
              hlcModified: hlc,
            ),
          );
      await db
          .into(db.qsoSync)
          .insert(
            QsoSyncCompanion.insert(
              qsoId: 'q$i',
              accountId: 'acc',
              state: state.name,
            ),
          );
    }
    expect(
      await SyncStatusRepository(db).watchPendingCount().first,
      SyncState.values.length - 1,
    );
  });

  test('counts the waiting QSOs per account', () async {
    final db = await openTestDatabase();
    const hlc = '000000000000000-0000-dev';
    for (final id in ['a', 'b', 'c']) {
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: id,
              label: id,
              baseUrl: 'https://$id.example.org',
              createdAt: 0,
            ),
          );
    }
    var n = 0;
    Future<void> qso(String account, SyncState state) async {
      n++;
      await db
          .into(db.qsos)
          .insert(
            QsosCompanion.insert(
              id: 'q$n',
              accountId: account,
              call: 'DL$n',
              timeOn: n,
              band: '20m',
              mode: 'CW',
              originDeviceId: 'dev',
              hlcCreated: hlc,
              hlcModified: hlc,
            ),
          );
      await db
          .into(db.qsoSync)
          .insert(
            QsoSyncCompanion.insert(
              qsoId: 'q$n',
              accountId: account,
              state: state.name,
            ),
          );
    }

    await qso('a', SyncState.queued);
    await qso('a', SyncState.queued);
    await qso('a', SyncState.synced);
    await qso('b', SyncState.queued);
    await qso('c', SyncState.synced);
    final repo = SyncStatusRepository(db);
    expect(await repo.watchPendingByAccount().first, {'a': 2, 'b': 1});
    expect(await repo.watchPendingCount().first, 3);
  });
}
