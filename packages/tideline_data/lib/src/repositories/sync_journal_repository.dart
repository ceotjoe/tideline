import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';

/// Kinds of journal entries. Stored by name: never rename.
enum JournalEvent {
  /// A QSO was logged locally.
  logged,

  /// A QSO was imported from a file.
  imported,

  /// A local edit was queued for upload.
  editQueued,

  /// A request started.
  requestStarted,

  /// The server stored the QSO (create/replace).
  uploaded,

  /// The server applied an edit.
  patched,

  /// The server deleted the QSO.
  deletedOnServer,

  /// The QSO was deleted locally only (no `qso:delete` permission).
  deletedLocallyOnly,

  /// A reconcile query found the QSO on the server.
  verifiedOnServer,

  /// A reconcile query found nothing; the QSO will be uploaded again.
  notOnServer,

  /// A retry was scheduled.
  retryScheduled,

  /// The server rejected the QSO.
  rejected,

  /// The QSO needs a decision from the user.
  conflict,

  /// The user resolved a conflict.
  conflictResolved,

  /// The account's token stopped working.
  accountBlocked,

  /// A sync run started.
  runStarted,

  /// A sync run finished.
  runFinished,
}

/// One journal entry.
@immutable
class JournalEntry {
  /// Creates an entry.
  const new({
    required this.id,
    required this.accountId,
    required this.at,
    required this.event,
    required this.detail,
    this.qsoId,
  });

  /// Sequence number.
  final int id;

  /// Account.
  final String accountId;

  /// Affected QSO, if any.
  final String? qsoId;

  /// UTC millis.
  final int at;

  /// What happened.
  final JournalEvent event;

  /// Redacted details (problem, server message, remote id, …).
  final Map<String, Object?> detail;
}

/// The append-only, user-visible sync journal.
class SyncJournalRepository {
  /// Creates the repository.
  new(this._db);

  final TidelineDatabase _db;

  /// Appends an entry. [detail] must already be redacted (no tokens).
  Future<void> append({
    required String accountId,
    required JournalEvent event,
    required int at,
    String? qsoId,
    Map<String, Object?> detail = const {},
  }) => _db
      .into(_db.syncJournal)
      .insert(
        SyncJournalCompanion.insert(
          accountId: accountId,
          qsoId: Value(qsoId),
          at: at,
          event: event.name,
          detail: Value(jsonEncode(detail)),
        ),
      );

  /// The newest [limit] entries, optionally for one QSO.
  Stream<List<JournalEntry>> watch({
    String? accountId,
    String? qsoId,
    int limit = 200,
  }) {
    final q = _db.select(_db.syncJournal)
      ..where((j) {
        final conditions = <Expression<bool>>[
          if (accountId != null) j.accountId.equals(accountId),
          if (qsoId != null) j.qsoId.equals(qsoId),
        ];
        return conditions.isEmpty
            ? const Constant(true)
            : conditions.reduce((a, b) => a & b);
      })
      ..orderBy([(j) => OrderingTerm.desc(j.id)])
      ..limit(limit);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          JournalEntry(
            id: r.id,
            accountId: r.accountId,
            qsoId: r.qsoId,
            at: r.at,
            event:
                JournalEvent.values.asNameMap()[r.event] ??
                JournalEvent.runStarted,
            detail: jsonDecode(r.detail) as Map<String, Object?>,
          ),
      ],
    );
  }

  /// Removes entries older than [olderThanMillis], keeping the newest
  /// [keep] regardless of age.
  Future<void> prune({required int olderThanMillis, int keep = 1000}) async {
    final newest =
        await (_db.selectOnly(_db.syncJournal)
              ..addColumns([_db.syncJournal.id])
              ..orderBy([OrderingTerm.desc(_db.syncJournal.id)])
              ..limit(1, offset: keep))
            .getSingleOrNull();
    final cutoffId = newest?.read(_db.syncJournal.id);
    if (cutoffId == null) return;
    await (_db.delete(_db.syncJournal)..where(
          (j) =>
              j.id.isSmallerOrEqualValue(cutoffId) &
              j.at.isSmallerThanValue(olderThanMillis),
        ))
        .go();
  }
}
