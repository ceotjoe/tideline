import 'package:meta/meta.dart';

/// Machine-readable reason a contest definition was rejected.
enum ContestDefinitionError {
  /// The input is larger than `ContestDefinition.maxInputBytes`.
  tooLarge,

  /// The input is not valid JSON.
  malformedJson,

  /// A value has the wrong JSON type (including a non-object root).
  wrongType,

  /// An object contains a key the schema does not define.
  unknownKey,

  /// A required key is missing.
  missingKey,

  /// `schema` is not 1.
  unsupportedSchema,

  /// `id` is not a `[a-z0-9-]{1,64}` slug.
  invalidId,

  /// A number (or string length minimum) is outside its allowed range.
  outOfRange,

  /// A string is longer than allowed.
  tooLong,

  /// A string contains control characters.
  invalidCharacters,

  /// A list is longer than allowed.
  tooManyElements,

  /// A list is shorter than required.
  tooFewElements,

  /// A band name is not in the ADIF Band enumeration.
  unknownBand,

  /// An enumerated string (mode category, kind, scope, …) is not known.
  unknownValue,

  /// The last point rule has a `when`, so some QSOs could match no rule.
  lastRuleHasWhen,

  /// An exchange variant `when` uses a predicate that is not `my*`.
  variantPredicateNotMine,

  /// A received exchange element `when` uses a predicate that is not
  /// `their*`.
  elementPredicateNotTheirs,

  /// A `when` is set on a sent exchange element.
  elementWhenNotAllowed,

  /// An exchange side contains more than one `serial` element.
  multipleSerials,

  /// Two elements of one side store into the same ADIF field.
  duplicateField,

  /// Two multipliers share an id.
  duplicateId,

  /// A `default` uses an unknown or malformed placeholder.
  invalidPlaceholder,

  /// A `default` is not valid for its element kind.
  invalidValue,

  /// A `default` is set where it is not allowed (received side, serial).
  defaultNotAllowed,

  /// A multiplier source is unknown or refers to an exchange element that
  /// no received exchange contains.
  invalidMultiplierSource,

  /// A `when` object is empty.
  emptyPredicate,

  /// The score kind does not fit the multipliers (for example
  /// `pointsTimesMultipliers` without any multiplier).
  invalidCombination,

  /// The same value is listed twice where values must be unique.
  duplicateValue,
}

/// Thrown by `ContestDefinition.parse` and `ContestDefinition.fromJson`.
///
/// The exception never contains the rejected value, only where and why, so it
/// is safe to log. The UI maps `reason` to a localised message.
@immutable
final class ContestDefinitionException implements Exception {
  /// Creates an exception.
  const new(this.reason, this.path, [this.detail]);

  /// Why the definition was rejected.
  final ContestDefinitionError reason;

  /// JSON path of the offending value, e.g. `$.exchange.sent[1].kind`.
  final String path;

  /// Optional developer-facing detail in English (not for the UI).
  final String? detail;

  @override
  String toString() =>
      'ContestDefinitionException(${reason.name} at $path'
      '${detail == null ? '' : ': $detail'})';
}
