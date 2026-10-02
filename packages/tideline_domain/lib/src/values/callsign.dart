import 'package:meta/meta.dart';

/// An amateur radio callsign, normalised to upper case.
///
/// Accepts portable and prefix forms such as `DO1HOZ/P`, `EA8/DO1HOZ` or
/// `DO1HOZ/MM`. Validation is deliberately permissive about structure (special
/// event calls vary widely) but strict about characters and length.
@immutable
final class Callsign {
  const new _(this.value);

  /// Parses user or import input; null if it cannot be a callsign.
  static Callsign? tryParse(String input) {
    final text = input.trim().toUpperCase();
    if (text.length < 3 || text.length > 20) return null;
    if (!_chars.hasMatch(text)) return null;
    if (text.startsWith('/') || text.endsWith('/') || text.contains('//')) {
      return null;
    }
    // Every callsign has a part with both a letter and a digit.
    final hasCallPart = text
        .split('/')
        .any((p) => p.contains(_digit) && p.contains(_letter));
    return hasCallPart ? Callsign._(text) : null;
  }

  static final RegExp _chars = RegExp(r'^[A-Z0-9/]+$');
  static final RegExp _digit = RegExp('[0-9]');
  static final RegExp _letter = RegExp('[A-Z]');

  /// Suffixes that indicate operating conditions, not location.
  static const Set<String> operatingSuffixes = {
    'P',
    'M',
    'MM',
    'AM',
    'QRP',
    'A',
    'LH',
  };

  /// The normalised callsign, e.g. `DO1HOZ/P`.
  final String value;

  /// The station's home callsign without prefixes or suffixes
  /// (`EA8/DO1HOZ/P` → `DO1HOZ`): the longest part with a letter and a digit.
  String get baseCall {
    final parts =
        value
            .split('/')
            .where((p) => p.contains(_digit) && p.contains(_letter))
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    return parts.first;
  }

  /// Characters separated by spaces, for screen readers that would otherwise
  /// pronounce the callsign as a word ("D O 1 H O Z").
  String get spelledOut => value.split('').join(' ');

  @override
  bool operator ==(Object other) => other is Callsign && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
