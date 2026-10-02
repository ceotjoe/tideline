import 'package:tideline_domain/src/contest/contest_definition_exception.dart';

/// Strict JSON reading helpers shared by the contest definition parsers.
///
/// Internal to the contest package; not exported.
abstract final class ContestJson {
  /// Upper bound for every list in a definition.
  static const int maxElements = 64;

  /// Throws a [ContestDefinitionException].
  static Never fail(
    ContestDefinitionError reason,
    String path, [
    String? detail,
  ]) => throw ContestDefinitionException(reason, path, detail);

  /// Path of child [key] of [path].
  static String child(String path, String key) => '$path.$key';

  /// Path of element [i] of [path].
  static String at(String path, int i) => '$path[$i]';

  /// Checks that [value] is an object with exactly the allowed keys.
  static Map<String, Object?> object(
    Object? value,
    String path, {
    Set<String> required = const {},
    Set<String> optional = const {},
  }) {
    if (value is! Map<Object?, Object?>) {
      fail(ContestDefinitionError.wrongType, path, 'expected an object');
    }
    final out = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        fail(ContestDefinitionError.wrongType, path, 'non-string key');
      }
      if (!required.contains(key) && !optional.contains(key)) {
        fail(ContestDefinitionError.unknownKey, child(path, _safe(key)));
      }
      out[key] = entry.value;
    }
    for (final key in required) {
      if (!out.containsKey(key)) {
        fail(ContestDefinitionError.missingKey, child(path, key));
      }
    }
    return out;
  }

  static String _safe(String key) {
    final cut = key.length > 40 ? key.substring(0, 40) : key;
    return cut.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '?');
  }

  /// A string of [min]..[max] UTF-16 code units without control characters.
  static String string(
    Object? value,
    String path, {
    int min = 1,
    int max = 120,
  }) {
    if (value is! String) {
      fail(ContestDefinitionError.wrongType, path, 'expected a string');
    }
    if (value.length > max) {
      fail(ContestDefinitionError.tooLong, path, 'longer than $max');
    }
    if (value.length < min) {
      fail(ContestDefinitionError.outOfRange, path, 'shorter than $min');
    }
    if (RegExp(r'[\x00-\x1f\x7f]').hasMatch(value)) {
      fail(ContestDefinitionError.invalidCharacters, path);
    }
    return value;
  }

  /// An integer in [min]..[max] (a JSON number with a fraction is rejected).
  static int integer(
    Object? value,
    String path, {
    required int min,
    required int max,
  }) {
    if (value is! int) {
      fail(ContestDefinitionError.wrongType, path, 'expected an integer');
    }
    if (value < min || value > max) {
      fail(ContestDefinitionError.outOfRange, path, '$min..$max');
    }
    return value;
  }

  /// A bool.
  static bool boolean(Object? value, String path) {
    if (value is! bool) {
      fail(ContestDefinitionError.wrongType, path, 'expected a bool');
    }
    return value;
  }

  /// A list of [min]..[maxElements] elements.
  static List<Object?> list(Object? value, String path, {int min = 0}) {
    if (value is! List<Object?>) {
      fail(ContestDefinitionError.wrongType, path, 'expected a list');
    }
    if (value.length > maxElements) {
      fail(ContestDefinitionError.tooManyElements, path, '> $maxElements');
    }
    if (value.length < min) {
      fail(ContestDefinitionError.tooFewElements, path, '< $min');
    }
    return value;
  }

  /// A string that must be one of [options] (matched by [nameOf]).
  static T enumValue<T>(
    Object? value,
    String path,
    Iterable<T> options,
    String Function(T) nameOf,
  ) {
    final text = string(value, path, max: 40);
    for (final option in options) {
      if (nameOf(option) == text) return option;
    }
    fail(ContestDefinitionError.unknownValue, path);
  }

  /// A scalar or a non-empty list of scalars, parsed with [one], without
  /// duplicates (order kept).
  static List<T> oneOrMany<T>(
    Object? value,
    String path,
    T Function(Object?, String) one, {
    int min = 1,
  }) {
    final items = <T>[];
    if (value is List<Object?>) {
      final raw = list(value, path, min: min);
      for (var i = 0; i < raw.length; i++) {
        items.add(one(raw[i], at(path, i)));
      }
    } else {
      items.add(one(value, path));
    }
    final seen = <T>{};
    for (final item in items) {
      if (!seen.add(item)) {
        fail(ContestDefinitionError.duplicateValue, path);
      }
    }
    return List.unmodifiable(items);
  }

  /// [items] as JSON: the bare value for one element, else a list.
  static Object? compact<T>(List<T> items, Object? Function(T) toJson) =>
      items.length == 1 ? toJson(items.single) : items.map(toJson).toList();
}
