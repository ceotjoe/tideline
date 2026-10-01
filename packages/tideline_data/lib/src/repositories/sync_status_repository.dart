import 'package:drift/drift.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Read-only views of sync progress for the UI.
class SyncStatusRepository {
  /// Creates the repository on top of [_db].
  new(this._db);

  final TidelineDatabase _db;

  /// Number of QSOs not yet [SyncState.synced], across all accounts.
  /// Drives the tide gauge.
  Stream<int> watchPendingCount() {
    final count = _db.qsoSync.qsoId.count();
    final query = _db.selectOnly(_db.qsoSync)
      ..addColumns([count])
      ..where(_db.qsoSync.state.equals(SyncState.synced.name).not());
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }
}
