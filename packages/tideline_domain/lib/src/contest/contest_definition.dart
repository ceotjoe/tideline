import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tideline_domain/src/contest/contest_definition_exception.dart';
import 'package:tideline_domain/src/contest/contest_json.dart';
import 'package:tideline_domain/src/contest/contest_predicate.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/exchange.dart';
import 'package:tideline_domain/src/contest/mode_category.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/mode.dart';

export 'package:tideline_domain/src/contest/contest_definition_exception.dart';

/// Which attributes, besides the call, make a contact unique.
enum DupeKey {
  /// The band.
  band,

  /// The ADIF mode (`SSB`, `CW`, `FT8`, …; submodes are not distinguished).
  mode,

  /// The mode category (`CW`, `PHONE`, `DIGI`).
  modeCategory,
}

/// The dupe rule: a contact is a dupe if an earlier one has the same call
/// and the same value for every key in [per].
@immutable
final class DupeRule {
  /// Creates a rule.
  const new(this.per);

  /// The keys; empty means once per contest.
  final List<DupeKey> per;

  /// A string identifying the "slot" (band/mode part) of a contact; two
  /// contacts with the same call and slot are dupes.
  String slotKey(Band band, Mode mode) {
    if (per.isEmpty) return '';
    final parts = <String>[
      for (final key in per)
        switch (key) {
          DupeKey.band => band.name,
          DupeKey.mode => mode.mode,
          DupeKey.modeCategory => ModeCategory.of(mode).jsonName,
        },
    ];
    return parts.join('|');
  }
}

/// One ordered points rule; the first matching rule gives the QSO's points.
@immutable
final class PointRule {
  /// Creates a rule.
  const new({required this.points, this.when});

  /// The condition, or null for "always" (required for the last rule).
  final ContestPredicate? when;

  /// Points for a matching QSO.
  final int points;
}

/// How long a multiplier value counts once.
enum MultiplierScope {
  /// Once per band.
  band('band'),

  /// Once per band and mode category.
  bandMode('bandMode'),

  /// Once per contest.
  contest('contest');

  new(this.jsonName);

  /// The name in definitions.
  final String jsonName;
}

/// The kinds of multiplier source.
enum MultiplierSourceKind {
  /// DXCC entity number.
  dxcc,

  /// CQ WPX prefix.
  wpxPrefix,

  /// A received exchange element (see [MultiplierSource.element]).
  rcvd,

  /// First four characters of the received grid.
  grid4,

  /// Their continent.
  continent,
}

/// Where a multiplier value comes from.
@immutable
final class MultiplierSource {
  /// Creates a source; [element] is required for [MultiplierSourceKind.rcvd].
  const new(this.kind, [this.element]);

  /// The source kind.
  final MultiplierSourceKind kind;

  /// The exchange element kind for [MultiplierSourceKind.rcvd].
  final ExchangeKind? element;

  /// The definition string, e.g. `dxcc` or `rcvd:cqZone`.
  String get jsonName =>
      kind == MultiplierSourceKind.rcvd ? 'rcvd:${element!.name}' : kind.name;
}

/// A multiplier: a set of values that each count once per [per] scope.
@immutable
final class MultiplierRule {
  /// Creates a rule.
  const new({
    required this.id,
    required this.source,
    required this.per,
    this.when,
  });

  /// Unique id within the definition, `[a-z0-9_-]{1,32}`.
  final String id;

  /// Where the value comes from.
  final MultiplierSource source;

  /// The counting scope.
  final MultiplierScope per;

  /// Only QSOs matching this count, or null for all.
  final ContestPredicate? when;
}

/// How the final score is computed.
enum ScoreKind {
  /// Sum of points times the number of multipliers.
  pointsTimesMultipliers,

  /// Sum of points (no multipliers).
  points,

  /// Number of valid (non-dupe) QSOs (no multipliers).
  qsos,
}

/// An exchange variant: the first one whose `when` matches my station
/// replaces `sent` and/or `rcvd`.
@immutable
final class ExchangeVariant {
  /// Creates a variant.
  const new({required this.when, this.sent, this.rcvd});

  /// A condition on my station (`my*` predicates only).
  final ContestPredicate when;

  /// Replacement for the sent exchange, or null to keep it.
  final List<ExchangeElement>? sent;

  /// Replacement for the received exchange, or null to keep it.
  final List<ExchangeElement>? rcvd;
}

/// The exchange that applies to one station.
@immutable
final class ResolvedExchange {
  /// Creates the result.
  const new({required this.sent, required this.rcvd});

  /// What I send, in entry order.
  final List<ExchangeElement> sent;

  /// What I receive, in entry order.
  final List<ExchangeElement> rcvd;
}

/// The contest exchange of a definition.
@immutable
final class ContestExchange {
  /// Creates an exchange.
  const new({required this.sent, required this.rcvd, this.variants = const []});

  /// What I send, in entry order.
  final List<ExchangeElement> sent;

  /// What I receive, in entry order.
  final List<ExchangeElement> rcvd;

  /// Optional variants, checked in order.
  final List<ExchangeVariant> variants;
}

/// A contest as data (ADR 0018).
///
/// Definitions are untrusted input; `parse` and `fromJson` validate
/// everything and throw [ContestDefinitionException] on the first problem.
/// Nothing in a definition is executable.
@immutable
final class ContestDefinition {
  /// Creates a definition without validation. Use `parse` for untrusted
  /// input.
  const new({
    required this.id,
    required this.version,
    required this.name,
    required this.modes,
    required this.bands,
    required this.exchange,
    required this.dupe,
    required this.points,
    required this.multipliers,
    required this.score,
    this.cabrillo,
    this.adif,
  });

  /// Parses and validates a definition file.
  ///
  /// Throws [ContestDefinitionException] for input over [maxInputBytes],
  /// malformed JSON or any schema violation.
  factory parse(String json) {
    if (json.length > maxInputBytes ||
        utf8.encode(json).length > maxInputBytes) {
      throw const ContestDefinitionException(
        ContestDefinitionError.tooLarge,
        r'$',
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const ContestDefinitionException(
        ContestDefinitionError.malformedJson,
        r'$',
      );
    }
    return ContestDefinition.fromJson(decoded);
  }

  /// Validates an already decoded JSON value (strictly the same rules as
  /// `parse`).
  factory fromJson(Object? json) {
    const root = r'$';
    final map = ContestJson.object(
      json,
      root,
      required: {
        'schema',
        'id',
        'version',
        'name',
        'modes',
        'bands',
        'exchange',
        'dupe',
        'score',
      },
      optional: {'cabrillo', 'adif', 'points', 'multipliers'},
    );
    String p(String key) => ContestJson.child(root, key);

    if (ContestJson.integer(map['schema'], p('schema'), min: 0, max: 1 << 31) !=
        1) {
      ContestJson.fail(ContestDefinitionError.unsupportedSchema, p('schema'));
    }
    final id = ContestJson.string(map['id'], p('id'), max: 200);
    if (!_idPattern.hasMatch(id)) {
      ContestJson.fail(ContestDefinitionError.invalidId, p('id'));
    }
    final version = ContestJson.integer(
      map['version'],
      p('version'),
      min: 1,
      max: 1000000,
    );
    final name = ContestJson.string(map['name'], p('name'));
    String? ident(String key) {
      if (!map.containsKey(key)) return null;
      final value = ContestJson.string(map[key], p(key), max: 40);
      if (!_identPattern.hasMatch(value)) {
        ContestJson.fail(ContestDefinitionError.invalidValue, p(key));
      }
      return value;
    }

    final cabrillo = ident('cabrillo');
    final adif = ident('adif');

    final modesRaw = ContestJson.list(map['modes'], p('modes'), min: 1);
    final modes = ContestJson.oneOrMany<ModeCategory>(
      modesRaw,
      p('modes'),
      (v, path) => ContestJson.enumValue(
        v,
        path,
        ModeCategory.values,
        (c) => c.jsonName,
      ),
    );
    final bandsRaw = ContestJson.list(map['bands'], p('bands'), min: 1);
    final bands = ContestJson.oneOrMany<Band>(bandsRaw, p('bands'), (v, path) {
      final text = ContestJson.string(v, path, max: 8);
      return Band.tryParse(text) ??
          ContestJson.fail(ContestDefinitionError.unknownBand, path);
    });

    final exchange = _parseExchange(map['exchange'], p('exchange'));

    final dupeMap = ContestJson.object(
      map['dupe'],
      p('dupe'),
      required: {'per'},
    );
    final dupe = DupeRule(
      ContestJson.oneOrMany<DupeKey>(
        ContestJson.list(dupeMap['per'], '${p('dupe')}.per'),
        '${p('dupe')}.per',
        (v, path) =>
            ContestJson.enumValue(v, path, DupeKey.values, (k) => k.name),
        min: 0,
      ),
    );

    final score = ContestJson.enumValue(
      map['score'],
      p('score'),
      ScoreKind.values,
      (k) => k.name,
    );

    final points = <PointRule>[];
    if (map.containsKey('points')) {
      final raw = ContestJson.list(map['points'], p('points'));
      for (var i = 0; i < raw.length; i++) {
        points.add(_parsePointRule(raw[i], ContestJson.at(p('points'), i)));
      }
    } else if (score != ScoreKind.qsos) {
      ContestJson.fail(ContestDefinitionError.missingKey, p('points'));
    }
    if (points.isNotEmpty && points.last.when != null) {
      ContestJson.fail(
        ContestDefinitionError.lastRuleHasWhen,
        '${ContestJson.at(p('points'), points.length - 1)}.when',
      );
    }
    if (points.isEmpty && score != ScoreKind.qsos) {
      ContestJson.fail(ContestDefinitionError.tooFewElements, p('points'));
    }

    final multipliers = <MultiplierRule>[];
    if (map.containsKey('multipliers')) {
      final raw = ContestJson.list(map['multipliers'], p('multipliers'));
      for (var i = 0; i < raw.length; i++) {
        multipliers.add(
          _parseMultiplier(raw[i], ContestJson.at(p('multipliers'), i)),
        );
      }
    }
    final ids = <String>{};
    for (var i = 0; i < multipliers.length; i++) {
      if (!ids.add(multipliers[i].id)) {
        ContestJson.fail(
          ContestDefinitionError.duplicateId,
          '${ContestJson.at(p('multipliers'), i)}.id',
        );
      }
    }
    final rcvdKinds = <ExchangeKind>{
      for (final e in exchange.rcvd) e.kind,
      for (final v in exchange.variants)
        for (final e in v.rcvd ?? const <ExchangeElement>[]) e.kind,
    };
    for (var i = 0; i < multipliers.length; i++) {
      final source = multipliers[i].source;
      final needs = switch (source.kind) {
        MultiplierSourceKind.rcvd => source.element,
        MultiplierSourceKind.grid4 => ExchangeKind.grid,
        _ => null,
      };
      if (needs != null && !rcvdKinds.contains(needs)) {
        ContestJson.fail(
          ContestDefinitionError.invalidMultiplierSource,
          '${ContestJson.at(p('multipliers'), i)}.source',
          'no received ${needs.name} element',
        );
      }
    }
    if (score == ScoreKind.pointsTimesMultipliers && multipliers.isEmpty) {
      ContestJson.fail(ContestDefinitionError.invalidCombination, p('score'));
    }
    if (score != ScoreKind.pointsTimesMultipliers && multipliers.isNotEmpty) {
      ContestJson.fail(ContestDefinitionError.invalidCombination, p('score'));
    }

    return ContestDefinition(
      id: id,
      version: version,
      name: name,
      cabrillo: cabrillo,
      adif: adif,
      modes: modes,
      bands: bands,
      exchange: exchange,
      dupe: dupe,
      points: List.unmodifiable(points),
      multipliers: List.unmodifiable(multipliers),
      score: score,
    );
  }

  /// Largest accepted definition file: 256 KiB.
  static const int maxInputBytes = 256 * 1024;

  static final RegExp _idPattern = RegExp(r'^[a-z0-9-]{1,64}$');
  static final RegExp _multIdPattern = RegExp(r'^[a-z0-9_-]{1,32}$');
  static final RegExp _identPattern = RegExp(r'^[A-Za-z0-9._+-]{1,40}$');

  static ContestExchange _parseExchange(Object? json, String path) {
    final map = ContestJson.object(
      json,
      path,
      required: {'sent', 'rcvd'},
      optional: {'variants'},
    );
    final sent = _parseElements(
      map['sent'],
      ContestJson.child(path, 'sent'),
      ExchangeSide.sent,
    );
    final rcvd = _parseElements(
      map['rcvd'],
      ContestJson.child(path, 'rcvd'),
      ExchangeSide.rcvd,
    );
    final variants = <ExchangeVariant>[];
    if (map.containsKey('variants')) {
      final vPath = ContestJson.child(path, 'variants');
      final raw = ContestJson.list(map['variants'], vPath);
      for (var i = 0; i < raw.length; i++) {
        final iPath = ContestJson.at(vPath, i);
        final v = ContestJson.object(
          raw[i],
          iPath,
          required: {'when'},
          optional: {'sent', 'rcvd'},
        );
        if (!v.containsKey('sent') && !v.containsKey('rcvd')) {
          ContestJson.fail(
            ContestDefinitionError.missingKey,
            ContestJson.child(iPath, 'sent'),
          );
        }
        final whenPath = ContestJson.child(iPath, 'when');
        final when = ContestPredicate.fromJson(v['when'], whenPath);
        if (!when.onlyMine) {
          ContestJson.fail(
            ContestDefinitionError.variantPredicateNotMine,
            whenPath,
          );
        }
        variants.add(
          ExchangeVariant(
            when: when,
            sent: v.containsKey('sent')
                ? _parseElements(
                    v['sent'],
                    ContestJson.child(iPath, 'sent'),
                    ExchangeSide.sent,
                  )
                : null,
            rcvd: v.containsKey('rcvd')
                ? _parseElements(
                    v['rcvd'],
                    ContestJson.child(iPath, 'rcvd'),
                    ExchangeSide.rcvd,
                  )
                : null,
          ),
        );
      }
    }
    return ContestExchange(
      sent: sent,
      rcvd: rcvd,
      variants: List.unmodifiable(variants),
    );
  }

  static List<ExchangeElement> _parseElements(
    Object? json,
    String path,
    ExchangeSide side,
  ) {
    final raw = ContestJson.list(json, path);
    final out = <ExchangeElement>[];
    var serials = 0;
    final fields = <String>{};
    for (var i = 0; i < raw.length; i++) {
      final element = ExchangeElement.fromJson(
        raw[i],
        ContestJson.at(path, i),
        side,
      );
      if (element.kind == ExchangeKind.serial && ++serials > 1) {
        ContestJson.fail(
          ContestDefinitionError.multipleSerials,
          ContestJson.at(path, i),
        );
      }
      final field = element.kind.fieldFor(side);
      final shared =
          field == ExchangeKind.stxString || field == ExchangeKind.srxString;
      if (!shared && !fields.add(field)) {
        ContestJson.fail(
          ContestDefinitionError.duplicateField,
          ContestJson.at(path, i),
        );
      }
      out.add(element);
    }
    return List.unmodifiable(out);
  }

  static PointRule _parsePointRule(Object? json, String path) {
    final map = ContestJson.object(
      json,
      path,
      required: {'points'},
      optional: {'when'},
    );
    return PointRule(
      points: ContestJson.integer(
        map['points'],
        ContestJson.child(path, 'points'),
        min: 0,
        max: 1000,
      ),
      when: map.containsKey('when')
          ? ContestPredicate.fromJson(
              map['when'],
              ContestJson.child(path, 'when'),
            )
          : null,
    );
  }

  static MultiplierRule _parseMultiplier(Object? json, String path) {
    final map = ContestJson.object(
      json,
      path,
      required: {'id', 'source', 'per'},
      optional: {'when'},
    );
    final idPath = ContestJson.child(path, 'id');
    final id = ContestJson.string(map['id'], idPath, max: 64);
    if (!_multIdPattern.hasMatch(id)) {
      ContestJson.fail(ContestDefinitionError.invalidId, idPath);
    }
    final sourcePath = ContestJson.child(path, 'source');
    final sourceText = ContestJson.string(map['source'], sourcePath, max: 32);
    final MultiplierSource source;
    if (sourceText.startsWith('rcvd:')) {
      final kind = ExchangeKind.values
          .where((k) => k.name == sourceText.substring(5))
          .firstOrNull;
      if (kind == null ||
          kind == ExchangeKind.rst ||
          kind == ExchangeKind.serial) {
        ContestJson.fail(
          ContestDefinitionError.invalidMultiplierSource,
          sourcePath,
        );
      }
      source = MultiplierSource(MultiplierSourceKind.rcvd, kind);
    } else {
      final kind = MultiplierSourceKind.values
          .where((k) => k != MultiplierSourceKind.rcvd && k.name == sourceText)
          .firstOrNull;
      if (kind == null) {
        ContestJson.fail(
          ContestDefinitionError.invalidMultiplierSource,
          sourcePath,
        );
      }
      source = MultiplierSource(kind);
    }
    return MultiplierRule(
      id: id,
      source: source,
      per: ContestJson.enumValue(
        map['per'],
        ContestJson.child(path, 'per'),
        MultiplierScope.values,
        (s) => s.jsonName,
      ),
      when: map.containsKey('when')
          ? ContestPredicate.fromJson(
              map['when'],
              ContestJson.child(path, 'when'),
            )
          : null,
    );
  }

  /// Stable slug, the primary key of a definition.
  final String id;

  /// Rules version; a session keeps the version it started with.
  final int version;

  /// Display name (a proper name, not localised).
  final String name;

  /// Cabrillo `CONTEST:` value, or null if Cabrillo export is not offered.
  final String? cabrillo;

  /// ADIF `CONTEST_ID` value.
  final String? adif;

  /// Mode categories allowed.
  final List<ModeCategory> modes;

  /// Bands allowed.
  final List<Band> bands;

  /// The exchange.
  final ContestExchange exchange;

  /// The dupe rule.
  final DupeRule dupe;

  /// Ordered point rules (first match wins).
  final List<PointRule> points;

  /// Multipliers.
  final List<MultiplierRule> multipliers;

  /// How the score is computed.
  final ScoreKind score;

  /// Whether [band] is allowed.
  bool allowsBand(Band band) => bands.contains(band);

  /// Whether [category] is allowed.
  bool allowsCategory(ModeCategory category) => modes.contains(category);

  /// The exchange for my station: the first variant whose `when` matches
  /// [me] replaces the sent and/or received elements.
  ResolvedExchange exchangeFor(ContestStation me) {
    for (final variant in exchange.variants) {
      if (variant.when.matches(me: me)) {
        return ResolvedExchange(
          sent: variant.sent ?? exchange.sent,
          rcvd: variant.rcvd ?? exchange.rcvd,
        );
      }
    }
    return ResolvedExchange(sent: exchange.sent, rcvd: exchange.rcvd);
  }

  /// The canonical JSON form; `ContestDefinition.fromJson(toJson())` is
  /// equal to this definition.
  Map<String, Object?> toJson() => {
    'schema': 1,
    'id': id,
    'version': version,
    'name': name,
    if (cabrillo != null) 'cabrillo': cabrillo,
    if (adif != null) 'adif': adif,
    'modes': [for (final m in modes) m.jsonName],
    'bands': [for (final b in bands) b.name],
    'exchange': {
      'sent': [for (final e in exchange.sent) e.toJson()],
      'rcvd': [for (final e in exchange.rcvd) e.toJson()],
      if (exchange.variants.isNotEmpty)
        'variants': [
          for (final v in exchange.variants)
            {
              'when': v.when.toJson(),
              if (v.sent != null) 'sent': [for (final e in v.sent!) e.toJson()],
              if (v.rcvd != null) 'rcvd': [for (final e in v.rcvd!) e.toJson()],
            },
        ],
    },
    'dupe': {
      'per': [for (final k in dupe.per) k.name],
    },
    'points': [
      for (final r in points)
        {if (r.when != null) 'when': r.when!.toJson(), 'points': r.points},
    ],
    'multipliers': [
      for (final m in multipliers)
        {
          'id': m.id,
          'source': m.source.jsonName,
          'per': m.per.jsonName,
          if (m.when != null) 'when': m.when!.toJson(),
        },
    ],
    'score': score.name,
  };

  String get _canonical => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      other is ContestDefinition && other._canonical == _canonical;

  @override
  int get hashCode => _canonical.hashCode;

  @override
  String toString() => 'ContestDefinition($id v$version)';
}
