import 'package:meta/meta.dart';
import 'package:tideline_domain/src/contest/contest_definition_exception.dart';
import 'package:tideline_domain/src/contest/contest_json.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/mode_category.dart';
import 'package:tideline_domain/src/values/maidenhead.dart';

/// Which side of the exchange: what I send or what I receive.
enum ExchangeSide {
  /// Sent by me.
  sent,

  /// Received from the other station.
  rcvd,
}

/// Why an exchange value was rejected. The UI localises these.
enum ExchangeError {
  /// A required value is empty.
  missing,

  /// The value does not have the shape the element kind requires.
  invalidFormat,

  /// The value has the right shape but is outside the allowed range.
  outOfRange,
}

/// A parsed element value: the normalised value, or the error.
typedef ExchangeValueResult = ({String? value, ExchangeError? error});

/// The kinds of exchange element and how each is stored in ADIF.
enum ExchangeKind {
  /// Signal report: `RST_SENT` / `RST_RCVD`.
  rst('RST_SENT', 'RST_RCVD'),

  /// Serial number: `STX` / `SRX`.
  serial('STX', 'SRX'),

  /// CQ zone 1-40: `STX_STRING` / `CQZ`.
  cqZone(ExchangeKind.stxString, 'CQZ'),

  /// ITU zone 1-90: `STX_STRING` / `ITUZ`.
  ituZone(ExchangeKind.stxString, 'ITUZ'),

  /// 4- or 6-character Maidenhead grid: `MY_GRIDSQUARE` / `GRIDSQUARE`.
  grid('MY_GRIDSQUARE', 'GRIDSQUARE'),

  /// State or province, 1-3 letters: `STX_STRING` / `STATE`.
  state(ExchangeKind.stxString, 'STATE'),

  /// ARRL/RAC section, 1-4 letters: `STX_STRING` / `ARRL_SECT`.
  section(ExchangeKind.stxString, 'ARRL_SECT'),

  /// DARC DOK: `STX_STRING` / `DARC_DOK`.
  dok(ExchangeKind.stxString, 'DARC_DOK'),

  /// Power: `TX_PWR` / `RX_PWR`.
  power('TX_PWR', 'RX_PWR'),

  /// Operator name: `STX_STRING` / `NAME`.
  name(ExchangeKind.stxString, 'NAME'),

  /// Free text `[A-Z0-9/]{1,12}`: `STX_STRING` / `SRX_STRING`.
  text(ExchangeKind.stxString, ExchangeKind.srxString);

  new(this.sentField, this.rcvdField);

  /// ADIF field holding sent strings.
  static const String stxString = 'STX_STRING';

  /// ADIF field holding received strings.
  static const String srxString = 'SRX_STRING';

  /// ADIF field this kind is stored in when sent.
  final String sentField;

  /// ADIF field this kind is stored in when received.
  final String rcvdField;

  /// The ADIF field for [side].
  String fieldFor(ExchangeSide side) =>
      side == ExchangeSide.sent ? sentField : rcvdField;

  static ExchangeValueResult _ok(String value) => (value: value, error: null);
  static ExchangeValueResult _err(ExchangeError e) => (value: null, error: e);

  static final RegExp _rst = RegExp(r'^[1-5][1-9][1-9]?$');
  static final RegExp _digits = RegExp(r'^[0-9]{1,5}$');
  static final RegExp _state = RegExp(r'^[A-Z]{1,3}$');
  static final RegExp _section = RegExp(r'^[A-Z]{1,4}$');
  static final RegExp _dok = RegExp(r'^[A-Z0-9]{1,6}$');
  static final RegExp _name = RegExp(r'^\p{L}{1,20}$', unicode: true);
  static final RegExp _text = RegExp(r'^[A-Z0-9/]{1,12}$');

  /// Validates and normalises [raw] (trimmed, upper case; numbers without
  /// leading zeros; grid in canonical case).
  ExchangeValueResult parse(String raw) {
    final text = raw.trim().toUpperCase();
    if (text.isEmpty) return _err(ExchangeError.missing);
    if (text.length > 64) return _err(ExchangeError.invalidFormat);
    ExchangeValueResult number(int min, int max) {
      if (!_digits.hasMatch(text)) return _err(ExchangeError.invalidFormat);
      final n = int.parse(text);
      if (n < min || n > max) return _err(ExchangeError.outOfRange);
      return _ok('$n');
    }

    ExchangeValueResult match(RegExp pattern) =>
        pattern.hasMatch(text) ? _ok(text) : _err(ExchangeError.invalidFormat);

    switch (this) {
      case ExchangeKind.rst:
        return match(_rst);
      case ExchangeKind.serial:
        return number(1, 99999);
      case ExchangeKind.cqZone:
        return number(1, 40);
      case ExchangeKind.ituZone:
        return number(1, 90);
      case ExchangeKind.grid:
        final grid = Maidenhead.normalize(text);
        return grid != null && (grid.length == 4 || grid.length == 6)
            ? _ok(grid)
            : _err(ExchangeError.invalidFormat);
      case ExchangeKind.state:
        return match(_state);
      case ExchangeKind.section:
        return match(_section);
      case ExchangeKind.dok:
        return match(_dok);
      case ExchangeKind.power:
        if (text == 'KW' || text == 'K' || text == 'QRP') return _ok(text);
        return number(1, 99999);
      case ExchangeKind.name:
        return match(_name);
      case ExchangeKind.text:
        return match(_text);
    }
  }
}

/// One element of a contest exchange.
@immutable
final class ExchangeElement {
  /// Creates an element.
  const new({
    required this.kind,
    this.label,
    this.defaultValue,
    this.optional = false,
  });

  /// Parses an element at [path]. [side] decides whether `default` is legal.
  factory fromJson(Object? json, String path, ExchangeSide side) {
    final map = ContestJson.object(
      json,
      path,
      required: {'kind'},
      optional: {'label', 'default', 'optional'},
    );
    final kind = ContestJson.enumValue(
      map['kind'],
      ContestJson.child(path, 'kind'),
      ExchangeKind.values,
      (k) => k.name,
    );
    String? label;
    if (map.containsKey('label')) {
      final p = ContestJson.child(path, 'label');
      label = ContestJson.string(map['label'], p, max: 32);
      if (!_labelPattern.hasMatch(label)) {
        ContestJson.fail(ContestDefinitionError.invalidValue, p);
      }
    }
    String? def;
    if (map.containsKey('default')) {
      final p = ContestJson.child(path, 'default');
      if (side != ExchangeSide.sent || kind == ExchangeKind.serial) {
        ContestJson.fail(ContestDefinitionError.defaultNotAllowed, p);
      }
      def = ContestJson.string(map['default'], p, max: 32);
      _checkDefault(kind, def, p);
    }
    final optional =
        map.containsKey('optional') &&
        ContestJson.boolean(
          map['optional'],
          ContestJson.child(path, 'optional'),
        );
    return ExchangeElement(
      kind: kind,
      label: label,
      defaultValue: def,
      optional: optional,
    );
  }

  static final RegExp _labelPattern = RegExp(r'^[a-z][a-zA-Z0-9]{0,31}$');
  static final RegExp _placeholder = RegExp(r'\{([A-Za-z0-9_]*)\}');

  /// The placeholders a sent `default` may use.
  static const Set<String> placeholders = {
    'MY_CQ_ZONE',
    'MY_ITU_ZONE',
    'MY_GRID4',
    'MY_STATE',
    'MY_DOK',
  };

  static void _checkDefault(ExchangeKind kind, String def, String path) {
    final matches = _placeholder.allMatches(def).toList();
    for (final m in matches) {
      if (!placeholders.contains(m[1])) {
        ContestJson.fail(ContestDefinitionError.invalidPlaceholder, path);
      }
    }
    final rest = def.replaceAll(_placeholder, '');
    if (rest.contains('{') || rest.contains('}')) {
      ContestJson.fail(ContestDefinitionError.invalidPlaceholder, path);
    }
    if (matches.isEmpty && kind.parse(def).error != null) {
      ContestJson.fail(ContestDefinitionError.invalidValue, path);
    }
  }

  /// What the element holds.
  final ExchangeKind kind;

  /// Suffix of the l10n key for the element's field label (e.g. `age`).
  final String? label;

  /// Default for the sent side; may contain placeholders from [placeholders].
  final String? defaultValue;

  /// Whether an empty value is acceptable.
  final bool optional;

  /// Validates [raw]. An empty optional value is valid and yields a null
  /// value without error.
  ExchangeValueResult check(String raw) {
    if (raw.trim().isEmpty) {
      return (value: null, error: optional ? null : ExchangeError.missing);
    }
    return kind.parse(raw);
  }

  /// The value to prefill for a sent element, or null.
  ///
  /// Uses `default` with placeholders resolved from [me]; an unknown
  /// placeholder value gives null. Without a `default`, an `rst` element
  /// gets 59 for phone and 599 otherwise. The result is validated.
  String? defaultFor(ContestStation me, {ModeCategory? category}) {
    final def = defaultValue;
    String? raw;
    if (def == null) {
      if (kind == ExchangeKind.rst) {
        raw = category == ModeCategory.phone ? '59' : '599';
      }
    } else {
      var unknown = false;
      raw = def.replaceAllMapped(_placeholder, (m) {
        final value = switch (m[1]) {
          'MY_CQ_ZONE' => me.cqz?.toString(),
          'MY_ITU_ZONE' => me.ituz?.toString(),
          'MY_GRID4' =>
            (me.grid?.length ?? 0) >= 4 ? me.grid!.substring(0, 4) : null,
          'MY_STATE' => me.state,
          'MY_DOK' => me.dok,
          _ => null,
        };
        if (value == null || value.trim().isEmpty) unknown = true;
        return value ?? '';
      });
      if (unknown) return null;
    }
    if (raw == null) return null;
    return kind.parse(raw).value;
  }

  /// The JSON form.
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    if (label != null) 'label': label,
    if (defaultValue != null) 'default': defaultValue,
    if (optional) 'optional': true,
  };
}

/// The ADIF form of one side of an exchange.
@immutable
final class ExchangeAdif {
  /// Creates the result.
  const new({this.rst, this.fields = const {}});

  /// The report: `Qso.rstSent` or `Qso.rstRcvd` depending on the side.
  final String? rst;

  /// All other ADIF fields by upper-case name, suitable for `Qso.fields`.
  final Map<String, String> fields;
}

/// Maps exchange element values to and from ADIF fields.
abstract final class ExchangeMapping {
  static final RegExp _space = RegExp(r'\s+');

  /// The ADIF form of [values] (parallel to [elements], already validated
  /// and normalised; empty strings mean "not given").
  ///
  /// - Elements that share `STX_STRING` (or `SRX_STRING`) are joined with a
  ///   single space, in exchange order.
  /// - If no element uses that string field, it receives a copy of the whole
  ///   exchange (all given values in order, including the report and serial)
  ///   so Wavelog shows what was typed.
  static ExchangeAdif toAdif(
    ExchangeSide side,
    List<ExchangeElement> elements,
    List<String> values,
  ) {
    if (elements.length != values.length) {
      throw ArgumentError.value(values, 'values', 'length differs');
    }
    final stringField = side == ExchangeSide.sent
        ? ExchangeKind.stxString
        : ExchangeKind.srxString;
    String? rst;
    final fields = <String, String>{};
    final stringParts = <String>[];
    final all = <String>[];
    for (var i = 0; i < elements.length; i++) {
      final value = values[i].trim();
      if (value.isEmpty) continue;
      all.add(value);
      final field = elements[i].kind.fieldFor(side);
      if (elements[i].kind == ExchangeKind.rst) {
        rst = value;
      } else if (field == stringField) {
        stringParts.add(value);
      } else {
        fields[field] = value;
      }
    }
    if (stringParts.isNotEmpty) {
      fields[stringField] = stringParts.join(' ');
    } else if (all.isNotEmpty) {
      fields[stringField] = all.join(' ');
    }
    return ExchangeAdif(rst: rst, fields: Map.unmodifiable(fields));
  }

  /// The inverse of [toAdif]: element values (empty string if absent),
  /// parallel to [elements]. [rst] is the QSO's report for [side].
  ///
  /// When several elements share the string field, its space-separated
  /// tokens are assigned in order; missing tokens give empty values.
  static List<String> fromAdif(
    ExchangeSide side,
    List<ExchangeElement> elements, {
    String? rst,
    Map<String, String> fields = const {},
  }) {
    final stringField = side == ExchangeSide.sent
        ? ExchangeKind.stxString
        : ExchangeKind.srxString;
    final sharing = [
      for (var i = 0; i < elements.length; i++)
        if (elements[i].kind != ExchangeKind.rst &&
            elements[i].kind.fieldFor(side) == stringField)
          i,
    ];
    final tokens = (fields[stringField] ?? '')
        .trim()
        .split(_space)
        .where((t) => t.isNotEmpty)
        .toList();
    final out = List<String>.filled(elements.length, '');
    for (var i = 0; i < elements.length; i++) {
      final kind = elements[i].kind;
      if (kind == ExchangeKind.rst) {
        out[i] = rst ?? '';
      } else if (kind.fieldFor(side) != stringField) {
        out[i] = fields[kind.fieldFor(side)] ?? '';
      }
    }
    if (sharing.length == 1) {
      out[sharing.single] = tokens.join(' ');
    } else {
      for (var k = 0; k < sharing.length && k < tokens.length; k++) {
        out[sharing[k]] = tokens[k];
      }
    }
    return out;
  }
}
