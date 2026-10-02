import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A stored contest definition with its origin.
@immutable
class StoredContestDefinition {
  /// Creates the pair.
  const new(this.definition, {required this.builtin});

  /// The parsed definition.
  final ContestDefinition definition;

  /// True for the bundled set, false for user imports.
  final bool builtin;
}

/// Why a user definition was not stored.
enum ContestImportError {
  /// The file is not a valid definition; see
  /// [ContestImportRejected.exception].
  invalid,

  /// The id belongs to a bundled definition, which users cannot replace.
  idClashesWithBuiltin,
}

/// Outcome of [ContestDefinitionRepository.importUserDefinition].
sealed class ContestImportResult {
  const new();
}

/// The definition was stored.
final class ContestImported extends ContestImportResult {
  /// Creates the result.
  const new(this.definition, {required this.replaced});

  /// What was stored.
  final ContestDefinition definition;

  /// Whether an earlier user definition with the same id was replaced.
  final bool replaced;
}

/// The definition was rejected; nothing was stored.
final class ContestImportRejected extends ContestImportResult {
  /// Creates the result.
  const new(this.error, {this.exception});

  /// The reason.
  final ContestImportError error;

  /// The parser's finding for [ContestImportError.invalid].
  final ContestDefinitionException? exception;
}

/// Outcome of [ContestDefinitionRepository.seedBuiltins].
@immutable
class ContestSeedReport {
  /// Creates a report.
  const new({
    this.inserted = const [],
    this.updated = const [],
    this.unchanged = const [],
    this.conflicts = const [],
    this.invalid = const [],
  });

  /// Ids that were new.
  final List<String> inserted;

  /// Ids whose stored builtin had a lower version.
  final List<String> updated;

  /// Ids already stored with the same or a newer version.
  final List<String> unchanged;

  /// Ids not stored because a user definition with that id exists.
  final List<String> conflicts;

  /// Bundled files that failed to parse (a packaging bug).
  final List<ContestDefinitionException> invalid;
}

/// Outcome of [ContestDefinitionRepository.delete].
enum ContestDeleteResult {
  /// The definition was removed.
  deleted,

  /// No such definition.
  notFound,

  /// Bundled definitions cannot be deleted.
  builtin,

  /// At least one session (even a deleted one) references it.
  inUse,
}

/// Contest definitions: the bundled set and user imports (ADR 0018).
///
/// Definitions are untrusted input. They are always parsed with
/// [ContestDefinition.parse] and stored in canonical form.
class ContestDefinitionRepository {
  /// Creates the repository.
  new(this._db);

  final TidelineDatabase _db;

  /// Stores the bundled definitions. A builtin is written only when it is
  /// new or has a higher version than the stored one. A user definition with
  /// the same id is never overwritten: the id is reported in
  /// [ContestSeedReport.conflicts].
  Future<ContestSeedReport> seedBuiltins(List<String> jsons) => _db.transaction(
    () async {
      final inserted = <String>[];
      final updated = <String>[];
      final unchanged = <String>[];
      final conflicts = <String>[];
      final invalid = <ContestDefinitionException>[];
      for (final json in jsons) {
        final ContestDefinition def;
        try {
          def = ContestDefinition.parse(json);
        } on ContestDefinitionException catch (e) {
          invalid.add(e);
          continue;
        }
        final existing = await _row(def.id);
        if (existing != null && !existing.builtin) {
          conflicts.add(def.id);
        } else if (existing == null) {
          await _db.into(_db.contestDefinitions).insert(_companion(def, true));
          inserted.add(def.id);
        } else if (existing.version < def.version) {
          await _db
              .into(_db.contestDefinitions)
              .insertOnConflictUpdate(_companion(def, true));
          updated.add(def.id);
        } else {
          unchanged.add(def.id);
        }
      }
      return ContestSeedReport(
        inserted: inserted,
        updated: updated,
        unchanged: unchanged,
        conflicts: conflicts,
        invalid: invalid,
      );
    },
  );

  /// Validates and stores a user definition. User mistakes are returned,
  /// not thrown. An earlier user definition with the same id is replaced.
  Future<ContestImportResult> importUserDefinition(String json) {
    final ContestDefinition def;
    try {
      def = ContestDefinition.parse(json);
    } on ContestDefinitionException catch (e) {
      return Future.value(
        ContestImportRejected(ContestImportError.invalid, exception: e),
      );
    }
    return _db.transaction<ContestImportResult>(() async {
      final existing = await _row(def.id);
      if (existing != null && existing.builtin) {
        return const ContestImportRejected(
          ContestImportError.idClashesWithBuiltin,
        );
      }
      await _db
          .into(_db.contestDefinitions)
          .insertOnConflictUpdate(_companion(def, false));
      return ContestImported(def, replaced: existing != null);
    });
  }

  /// All definitions, sorted by name.
  Stream<List<StoredContestDefinition>> watchAll() =>
      (_db.select(
        _db.contestDefinitions,
      )..orderBy([(d) => OrderingTerm.asc(d.name)])).watch().map(
        (rows) => [
          for (final r in rows)
            if (_parse(r) case final def?)
              StoredContestDefinition(def, builtin: r.builtin),
        ],
      );

  /// The definition [id], or null.
  Future<ContestDefinition?> find(String id) async {
    final row = await _row(id);
    return row == null ? null : _parse(row);
  }

  /// Removes a user definition that no session uses.
  Future<ContestDeleteResult> delete(String id) => _db.transaction(() async {
    final row = await _row(id);
    if (row == null) return ContestDeleteResult.notFound;
    if (row.builtin) return ContestDeleteResult.builtin;
    final used =
        await (_db.select(_db.contestSessions)
              ..where((s) => s.definitionId.equals(id))
              ..limit(1))
            .get();
    if (used.isNotEmpty) return ContestDeleteResult.inUse;
    await (_db.delete(
      _db.contestDefinitions,
    )..where((d) => d.id.equals(id))).go();
    return ContestDeleteResult.deleted;
  });

  Future<ContestDefinitionRow?> _row(String id) => (_db.select(
    _db.contestDefinitions,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

  ContestDefinition? _parse(ContestDefinitionRow row) {
    try {
      return ContestDefinition.parse(row.definition);
    } on ContestDefinitionException {
      // Stored definitions were validated on the way in; skip a damaged row
      // rather than break the whole list.
      return null;
    }
  }

  ContestDefinitionsCompanion _companion(ContestDefinition d, bool builtin) =>
      ContestDefinitionsCompanion.insert(
        id: d.id,
        name: d.name,
        cabrilloName: Value(d.cabrillo),
        wavelogAdifName: Value(d.adif),
        version: d.version,
        definition: jsonEncode(d.toJson()),
        builtin: Value(builtin),
      );
}
