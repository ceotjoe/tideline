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
}
