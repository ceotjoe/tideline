import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Metadata of the installed MASTER.SCP.
@immutable
class ScpPackInfo {
  /// Creates the info.
  const new({
    required this.callCount,
    required this.sha256,
    required this.sourceUrl,
    required this.fetchedAt,
  });

  /// Number of calls stored.
  final int callCount;

  /// SHA-256 (hex) of the downloaded text.
  final String sha256;

  /// Where the user downloaded it from.
  final String sourceUrl;

  /// When it was downloaded (UTC millis).
  final int fetchedAt;
}

/// The user-downloaded MASTER.SCP (never bundled, ADR 0018) in `scp_calls`.
class ScpStore {
  /// Creates the store.
  new(this._db);

  final TidelineDatabase _db;

  static const String _packId = 'scp';

  /// Parses [text] and replaces the stored calls and the `reference_packs`
  /// row in one transaction. Throws [ScpFormatException] for oversized input
  /// before anything is changed.
  Future<ScpPackInfo> replace(
    String text, {
    required String sourceUrl,
    required DateTime fetchedAt,
  }) async {
    final database = ScpDatabase.parse(text);
    final sha = crypto.sha256.convert(utf8.encode(text)).toString();
    final at = fetchedAt.toUtc();
    await _db.transaction(() async {
      await _db.delete(_db.scpCalls).go();
      await _db.batch((b) {
        b.insertAll(_db.scpCalls, [
          for (final call in database.calls)
            ScpCallsCompanion.insert(call: call),
        ]);
      });
      await _db
          .into(_db.referencePacks)
          .insertOnConflictUpdate(
            ReferencePacksCompanion.insert(
              id: _packId,
              kind: 'scp',
              version: at.toIso8601String().substring(0, 10),
              sourceUrl: sourceUrl,
              sha256: sha,
              fetchedAt: at.millisecondsSinceEpoch,
            ),
          );
    });
    return ScpPackInfo(
      callCount: database.length,
      sha256: sha,
      sourceUrl: sourceUrl,
      fetchedAt: at.millisecondsSinceEpoch,
    );
  }

  /// The stored database, or null when none is installed.
  Future<ScpDatabase?> load() async {
    final rows = await _db.select(_db.scpCalls).get();
    if (rows.isEmpty) return null;
    return ScpDatabase.parse(rows.map((r) => r.call).join('\n'));
  }

  /// Metadata of the installed pack, or null.
  Future<ScpPackInfo?> info() async {
    final pack = await (_db.select(
      _db.referencePacks,
    )..where((p) => p.id.equals(_packId))).getSingleOrNull();
    if (pack == null) return null;
    final count = _db.scpCalls.call.count();
    final n = await (_db.selectOnly(
      _db.scpCalls,
    )..addColumns([count])).map((r) => r.read(count)!).getSingle();
    return ScpPackInfo(
      callCount: n,
      sha256: pack.sha256,
      sourceUrl: pack.sourceUrl,
      fetchedAt: pack.fetchedAt,
    );
  }

  /// Removes the calls and the pack record.
  Future<void> clear() => _db.transaction(() async {
    await _db.delete(_db.scpCalls).go();
    await (_db.delete(
      _db.referencePacks,
    )..where((p) => p.id.equals(_packId))).go();
  });
}
