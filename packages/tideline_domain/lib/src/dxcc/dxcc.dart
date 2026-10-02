import 'package:meta/meta.dart';

/// A DXCC entity (or WAE-only entity) from the AD1C country files.
@immutable
class DxccEntity {
  /// Creates an entity.
  const new({
    required this.primaryPrefix,
    required this.name,
    required this.dxcc,
    required this.continent,
    required this.cqz,
    required this.ituz,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetHours,
    required this.waeOnly,
  });

  /// Primary prefix, e.g. `DL`, `IT9`.
  final String primaryPrefix;

  /// Entity name as in the country files.
  final String name;

  /// ADIF DXCC entity code.
  final int dxcc;

  /// Continent: AF, AN, AS, EU, NA, OC or SA.
  final String continent;

  /// CQ zone.
  final int cqz;

  /// ITU zone.
  final int ituz;

  /// Latitude, north positive.
  final double latitude;

  /// Longitude, east positive (converted from the file's west-positive).
  final double longitude;

  /// Local time offset from UTC in hours.
  final double utcOffsetHours;

  /// Counts for the DARC WAE list / CQ contests but is not a separate
  /// ARRL DXCC entity (e.g. Sicily, Shetland Islands).
  final bool waeOnly;
}

/// Result of resolving a callsign.
@immutable
class DxccMatch {
  /// Creates a match.
  const new({
    required this.entity,
    required this.cqz,
    required this.ituz,
    required this.continent,
    required this.latitude,
    required this.longitude,
    this.waeEntity,
  });

  /// The ARRL DXCC entity.
  final DxccEntity entity;

  /// The WAE-only entity when it differs (e.g. Sicily for an IT9 call).
  final DxccEntity? waeEntity;

  /// CQ zone, after per-prefix/per-call overrides.
  final int cqz;

  /// ITU zone, after overrides.
  final int ituz;

  /// Continent, after overrides.
  final String continent;

  /// Latitude, after overrides.
  final double latitude;

  /// Longitude (east positive), after overrides.
  final double longitude;
}

class _Alias {
  const new(
    this.entity, {
    this.cqz,
    this.ituz,
    this.continent,
    this.latitude,
    this.longitude,
  });

  final DxccEntity entity;
  final int? cqz;
  final int? ituz;
  final String? continent;
  final double? latitude;
  final double? longitude;
}

/// Offline callsign → DXCC resolution from AD1C's `cty.csv`.
///
/// Implements the documented country-file semantics: `=CALL` exact
/// matches, longest-prefix matching, per-alias overrides `(cq)`, `[itu]`,
/// `<lat/lon>`, `{continent}`, `~offset~`, and first-occurrence-wins.
class DxccDatabase {
  new _(this.entities, this._exact, this._prefixes, this._byDxcc);

  /// Parses the contents of `cty.csv`. Malformed lines are skipped.
  factory parseCsv(String csv) {
    final entities = <DxccEntity>[];
    final exact = <String, _Alias>{};
    final prefixes = <String, _Alias>{};
    for (final line in csv.split(RegExp(r'\r?\n'))) {
      final cols = line.split(',');
      if (cols.length < 10) continue;
      final dxcc = int.tryParse(cols[2]);
      final cq = int.tryParse(cols[4]);
      final itu = int.tryParse(cols[5]);
      final lat = double.tryParse(cols[6]);
      final lonWest = double.tryParse(cols[7]);
      final offset = double.tryParse(cols[8]);
      if (dxcc == null ||
          cq == null ||
          itu == null ||
          lat == null ||
          lonWest == null ||
          offset == null) {
        continue;
      }
      final waeOnly = cols[0].startsWith('*');
      final entity = DxccEntity(
        primaryPrefix: cols[0].replaceFirst('*', ''),
        name: cols[1],
        dxcc: dxcc,
        continent: cols[3],
        cqz: cq,
        ituz: itu,
        latitude: lat,
        longitude: -lonWest,
        utcOffsetHours: -offset,
        waeOnly: waeOnly,
      );
      entities.add(entity);
      final aliasText = cols.sublist(9).join(',').replaceAll(';', '');
      for (final raw in aliasText.split(RegExp(r'\s+'))) {
        if (raw.isEmpty) continue;
        final parsed = _parseAlias(raw, entity);
        if (parsed == null) continue;
        final (key, alias, isExact) = parsed;
        // First occurrence wins.
        (isExact ? exact : prefixes).putIfAbsent(key, () => alias);
      }
    }
    final byDxcc = <int, DxccEntity>{};
    for (final e in entities) {
      if (!e.waeOnly) byDxcc.putIfAbsent(e.dxcc, () => e);
    }
    return DxccDatabase._(entities, exact, prefixes, byDxcc);
  }

  /// All entities in file order.
  final List<DxccEntity> entities;
  final Map<String, _Alias> _exact;
  final Map<String, _Alias> _prefixes;
  final Map<int, DxccEntity> _byDxcc;

  static final RegExp _aliasPattern = RegExp(
    r'^(=?)([A-Z0-9/]+)(?:\((\d+)\))?(?:\[(\d+)\])?'
    r'(?:<(-?[\d.]+)/(-?[\d.]+)>)?(?:\{([A-Z]{2})\})?(?:~(-?[\d.]+)~)?$',
  );

  static (String, _Alias, bool)? _parseAlias(String raw, DxccEntity entity) {
    final m = _aliasPattern.firstMatch(raw);
    if (m == null) return null;
    final lat = m[5] == null ? null : double.tryParse(m[5]!);
    final lonWest = m[6] == null ? null : double.tryParse(m[6]!);
    return (
      m[2]!,
      _Alias(
        entity,
        cqz: m[3] == null ? null : int.parse(m[3]!),
        ituz: m[4] == null ? null : int.parse(m[4]!),
        latitude: lat,
        longitude: lonWest == null ? null : -lonWest,
        continent: m[7],
      ),
      m[1] == '=',
    );
  }

  /// The non-WAE entity with ADIF code [dxcc], if known.
  DxccEntity? entityByDxcc(int dxcc) => _byDxcc[dxcc];

  /// Resolves [callsign] (already upper-case), or null if unknown or
  /// without a DXCC entity (maritime/aeronautical mobile).
  DxccMatch? resolve(String callsign) {
    final call = callsign.trim().toUpperCase();
    if (call.isEmpty) return null;
    final exact = _exact[call];
    if (exact != null) return _match(exact);
    final key = _lookupKey(call);
    if (key == null) return null;
    for (var i = key.length; i > 0; i--) {
      final alias = _prefixes[key.substring(0, i)];
      if (alias != null) return _match(alias);
    }
    return null;
  }

  DxccMatch _match(_Alias alias) {
    final e = alias.entity;
    final dxccEntity = e.waeOnly ? (_byDxcc[e.dxcc] ?? e) : e;
    return DxccMatch(
      entity: dxccEntity,
      waeEntity: e.waeOnly ? e : null,
      cqz: alias.cqz ?? e.cqz,
      ituz: alias.ituz ?? e.ituz,
      continent: alias.continent ?? e.continent,
      latitude: alias.latitude ?? e.latitude,
      longitude: alias.longitude ?? e.longitude,
    );
  }

  static const _operatingSuffixes = {'P', 'M', 'QRP', 'A', 'LH', 'QRPP'};

  /// The string whose prefixes determine the entity, or null for maritime
  /// or aeronautical mobile, which count for no entity.
  static String? _lookupKey(String call) {
    var parts = call.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.any((p) => p == 'MM' || p == 'AM')) return null;
    parts = parts.where((p) => !_operatingSuffixes.contains(p)).toList();
    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts.first;

    // W1AW/4: a single digit changes the call area.
    final last = parts.last;
    if (parts.length == 2 && RegExp(r'^\d$').hasMatch(last)) {
      final base = parts.first;
      final m = RegExp(r'^([A-Z0-9]*?[A-Z])(\d+)').firstMatch(base);
      return m == null ? base : '${m[1]}$last';
    }
    // EA8/DO1HOZ or DO1HOZ/EA8: the shorter part is the location prefix.
    final sorted = [...parts]..sort((a, b) => a.length.compareTo(b.length));
    return sorted.first;
  }
}
