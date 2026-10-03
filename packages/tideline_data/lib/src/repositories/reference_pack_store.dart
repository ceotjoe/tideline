import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Metadata of an installed SOTA, POTA or WWFF pack.
@immutable
class ReferencePackInfo {
  /// Creates the info.
  const new({
    required this.program,
    required this.count,
    required this.sha256,
    required this.sourceUrl,
    required this.fetchedAt,
    required this.version,
    this.licenceNote,
  });

  /// The programme.
  final ReferenceProgram program;

  /// Number of references stored.
  final int count;

  /// SHA-256 (hex) of the downloaded file.
  final String sha256;

  /// Where the user downloaded it from.
  final String sourceUrl;

  /// When it was downloaded (UTC millis).
  final int fetchedAt;

  /// The date the source gives itself (SOTA), otherwise the fetch date, as
  /// `yyyy-mm-dd`.
  final String version;

  /// The licence note recorded with the pack, if any.
  final String? licenceNote;
}

/// A reference together with its distance from a point.
typedef NearbyReference = ({ProgramReference reference, double km});

/// The user-downloaded SOTA, POTA and WWFF reference lists (never bundled,
/// ADR 0013) in `program_references`, with their `reference_packs` rows.
class ReferencePackStore {
  /// Creates the store.
  new(this._db);

  final TidelineDatabase _db;

  static const String _staging = 'program_references_staging';
  static const String _like = r"LIKE ? ESCAPE '\'";
  static const int _batchSize = 500;
  static const List<double> _radiiKm = [25, 100, 400, 1500, 6000, 20100];

  bool _installing = false;

  /// Installs a pack from [references], replacing the installed one.
  ///
  /// The rows are first collected in a temporary table while the app keeps
  /// reading the database. Only when the whole stream has arrived are the old
  /// rows swapped for the new ones, in one transaction. If the stream throws,
  /// or the app stops, the installed pack is untouched.
  ///
  /// Throws [StateError] if another install is running, and
  /// [ArgumentError] if a reference belongs to another programme.
  Future<ReferencePackInfo> install(
    ReferenceProgram program,
    Stream<ProgramReference> references, {
    required String sourceUrl,
    required String sha256,
    required DateTime fetchedAt,
    DateTime? sourceDate,
    String? licenceNote,
  }) async {
    if (_installing) {
      throw StateError('A reference pack is already being installed');
    }
    _installing = true;
    try {
      await _db.customStatement('DROP TABLE IF EXISTS $_staging');
      await _db.customStatement(
        'CREATE TEMP TABLE $_staging ( '
        'program TEXT NOT NULL, ref TEXT NOT NULL, name TEXT NOT NULL, '
        'region TEXT, lat REAL, lon REAL, valid_from INTEGER, '
        'valid_to INTEGER, active INTEGER NOT NULL, '
        'PRIMARY KEY (program, ref))',
      );
      var pending = <ProgramReference>[];
      Future<void> flush() async {
        if (pending.isEmpty) return;
        final rows = pending;
        pending = <ProgramReference>[];
        await _db.batch((b) {
          for (final r in rows) {
            b.customStatement(
              'INSERT OR REPLACE INTO $_staging VALUES (?,?,?,?,?,?,?,?,?)',
              [
                r.program.code,
                r.reference,
                r.name,
                r.region,
                r.latitude,
                r.longitude,
                r.validFrom?.millisecondsSinceEpoch,
                r.validTo?.millisecondsSinceEpoch,
                if (r.active) 1 else 0,
              ],
            );
          }
        });
      }

      await for (final r in references) {
        if (r.program != program) {
          throw ArgumentError.value(
            r.program,
            'references',
            'does not belong to ${program.code}',
          );
        }
        pending.add(r);
        if (pending.length >= _batchSize) await flush();
      }
      await flush();

      final fetched = fetchedAt.toUtc();
      final version = (sourceDate ?? fetched).toUtc().toIso8601String();
      late int count;
      await _db.transaction(() async {
        await (_db.delete(
          _db.programReferences,
        )..where((r) => r.program.equals(program.code))).go();
        await _db.customStatement(
          'INSERT INTO program_references '
          '(program, ref, name, region, lat, lon, valid_from, valid_to, '
          'active) SELECT program, ref, name, region, lat, lon, valid_from, '
          'valid_to, active FROM $_staging',
        );
        count = await _count(program);
        await _db
            .into(_db.referencePacks)
            .insertOnConflictUpdate(
              ReferencePacksCompanion.insert(
                id: program.name,
                kind: program.name,
                version: version.substring(0, 10),
                sourceUrl: sourceUrl,
                sha256: sha256,
                fetchedAt: fetched.millisecondsSinceEpoch,
                licenceNote: Value(licenceNote),
              ),
            );
      });
      return ReferencePackInfo(
        program: program,
        count: count,
        sha256: sha256,
        sourceUrl: sourceUrl,
        fetchedAt: fetched.millisecondsSinceEpoch,
        version: version.substring(0, 10),
        licenceNote: licenceNote,
      );
    } finally {
      await _db.customStatement('DROP TABLE IF EXISTS $_staging');
      _installing = false;
    }
  }

  /// Metadata of the installed pack, or null.
  Future<ReferencePackInfo?> info(ReferenceProgram program) async {
    final pack = await _packRow(program).getSingleOrNull();
    return pack == null ? null : _info(program, pack, await _count(program));
  }

  /// Emits the installed pack's metadata whenever it changes.
  Stream<ReferencePackInfo?> watchInfo(ReferenceProgram program) {
    return _packRow(program).watchSingleOrNull().asyncMap((pack) async {
      return pack == null ? null : _info(program, pack, await _count(program));
    });
  }

  /// One reference, or null if the pack does not contain it.
  Future<ProgramReference?> find(ReferenceProgram program, String ref) async {
    final row =
        await (_db.select(_db.programReferences)..where(
              (r) =>
                  r.program.equals(program.code) &
                  r.ref.equals(ref.trim().toUpperCase()),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Searches reference, name and region. Every word of [query] must match
  /// one of them (letter case is ignored for ASCII only). Exact reference
  /// matches come first, then prefix matches.
  ///
  /// Retired references are left out unless [includeInactive] is set.
  Future<List<ProgramReference>> search(
    String query, {
    ReferenceProgram? program,
    int limit = 50,
    bool includeInactive = false,
  }) async {
    final words = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(5)
        .toList();
    if (words.isEmpty) return const [];
    final where = <String>[];
    final vars = <Variable<Object>>[];
    if (program != null) {
      where.add('program = ?');
      vars.add(Variable.withString(program.code));
    }
    if (!includeInactive) where.add('active = 1');
    for (final w in words) {
      where.add('(ref $_like OR name $_like OR region $_like)');
      final like = '%${_escapeLike(w)}%';
      vars.addAll([
        Variable.withString(like),
        Variable.withString(like),
        Variable.withString(like),
      ]);
    }
    final first = words.first;
    final rows = await _db
        .customSelect(
          'SELECT * FROM program_references WHERE ${where.join(' AND ')} '
          'ORDER BY CASE WHEN ref = ? THEN 0 '
          'WHEN ref $_like THEN 1 '
          'WHEN name $_like THEN 2 ELSE 3 END, ref LIMIT ?',
          variables: [
            ...vars,
            Variable.withString(first.toUpperCase()),
            Variable.withString('${_escapeLike(first)}%'),
            Variable.withString('${_escapeLike(first)}%'),
            Variable.withInt(limit.clamp(1, 500)),
          ],
          readsFrom: {_db.programReferences},
        )
        .map((r) => _toDomain(_db.programReferences.map(r.data)))
        .get();
    return rows;
  }

  /// The [limit] references of [program] nearest to the point, closest
  /// first. References without coordinates and, unless [includeInactive] is
  /// set, retired ones are left out.
  ///
  /// The search widens ring by ring, so a dense area never reads the whole
  /// pack.
  Future<List<NearbyReference>> nearest(
    ReferenceProgram program,
    double latitude,
    double longitude, {
    int limit = 20,
    bool includeInactive = false,
  }) async {
    var found = <NearbyReference>[];
    for (final radius in _radiiKm) {
      final box = GeoDistance.boundingBox(latitude, longitude, radius);
      final lonSql = [for (final _ in box.lonRanges) '(lon BETWEEN ? AND ?)']
          .join(' OR ');
      final rows = await _db
          .customSelect(
            'SELECT * FROM program_references WHERE program = ? '
            '${includeInactive ? '' : 'AND active = 1 '}'
            'AND lat BETWEEN ? AND ? AND ($lonSql)',
            variables: [
              Variable.withString(program.code),
              Variable.withReal(box.minLat),
              Variable.withReal(box.maxLat),
              for (final r in box.lonRanges) ...[
                Variable.withReal(r.min),
                Variable.withReal(r.max),
              ],
            ],
            readsFrom: {_db.programReferences},
          )
          .map((r) => _toDomain(_db.programReferences.map(r.data)))
          .get();
      found = GeoDistance.nearest(
        rows,
        latitude,
        longitude,
        limit: rows.length,
      ).where((e) => e.km <= radius).toList();
      if (found.length >= limit || radius == _radiiKm.last) break;
    }
    return found.length > limit ? found.sublist(0, limit) : found;
  }

  /// Removes the references and the pack record of [program].
  Future<void> clear(ReferenceProgram program) => _db.transaction(() async {
    await (_db.delete(
      _db.programReferences,
    )..where((r) => r.program.equals(program.code))).go();
    await (_db.delete(
      _db.referencePacks,
    )..where((p) => p.id.equals(program.name))).go();
  });

  SimpleSelectStatement<$ReferencePacksTable, ReferencePackRow> _packRow(
    ReferenceProgram program,
  ) => _db.select(_db.referencePacks)..where((p) => p.id.equals(program.name));

  Future<int> _count(ReferenceProgram program) {
    final count = _db.programReferences.ref.count();
    return (_db.selectOnly(_db.programReferences)
          ..addColumns([count])
          ..where(_db.programReferences.program.equals(program.code)))
        .map((r) => r.read(count)!)
        .getSingle();
  }

  static ReferencePackInfo _info(
    ReferenceProgram program,
    ReferencePackRow pack,
    int count,
  ) => ReferencePackInfo(
    program: program,
    count: count,
    sha256: pack.sha256,
    sourceUrl: pack.sourceUrl,
    fetchedAt: pack.fetchedAt,
    version: pack.version,
    licenceNote: pack.licenceNote,
  );

  static ProgramReference _toDomain(ProgramReferenceRow row) =>
      ProgramReference(
        program: ReferenceProgram.tryParse(row.program)!,
        reference: row.ref,
        name: row.name,
        region: row.region,
        latitude: row.lat,
        longitude: row.lon,
        validFrom: row.validFrom == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row.validFrom!, isUtc: true),
        validTo: row.validTo == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row.validTo!, isUtc: true),
        active: row.active,
      );

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
