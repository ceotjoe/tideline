import 'package:tideline_domain/src/values/callsign.dart';

/// CQ WPX prefix extraction.
///
/// The prefix is the leading letters and digits of a call up to and
/// including the last digit that is followed only by letters.
///
/// Assumptions, following the CQ WPX rules:
/// - `N8BJQ` gives `N8`, `WA9ALS` gives `WA9`, `9A1A` gives `9A1`, `2E0ABC`
///   gives `2E0`, `3DA0XX` gives `3DA0`.
/// - A call without a digit gets `0` appended to its first two letters
///   (`RAEM` gives `RA0`).
/// - Operating suffixes in [Callsign.operatingSuffixes] (`/P`, `/M`, `/MM`,
///   `/AM`, `/QRP`, `/A`, `/LH`) and licence-class identifiers (`/E`, `/J`,
///   `/AE`, `/AG`) are ignored. (The official rules do not give
///   multiplier credit for `/MM` and `/AM`; this function still returns the
///   home prefix, so the caller can decide.)
/// - A single trailing digit (`/7`) replaces the digit of the prefix:
///   `K1ABC/2` gives `K2`, `OH2AAA/7` gives `OH7`. A prefix without a digit
///   gets that digit: `RAEM/3` gives `RA3`.
/// - The other part of a two-part call (`EA8/DL1ABC`, `DL1ABC/EA8`) is the
///   prefix if it ends in a digit (`EA8`); otherwise `0` is appended
///   (`LX/DL1ABC` gives `LX0`, `PA/DL1ABC/P` gives `PA0`, `9A/DL1ABC` gives
///   `9A0`).
/// - Which part is the call: the part that ends in letters after a digit and
///   has at least three characters; if both do, the first; if neither does,
///   the longer.
/// - Anything with more than two parts after removing suffixes and a trailing
///   digit, or with characters other than `A-Z0-9/`, gives null.
abstract final class WpxPrefix {
  /// Licence-class identifiers, which the rules say are not prefixes.
  static const Set<String> _licenceClass = {'E', 'J', 'AE', 'AG'};

  static final RegExp _valid = RegExp(r'^[A-Z0-9]+$');
  static final RegExp _callLike = RegExp(r'^[A-Z0-9]*[0-9][A-Z]+$');
  static final RegExp _split = RegExp(r'^([A-Z0-9]*[0-9])[A-Z]+$');
  static final RegExp _lastDigits = RegExp(r'[0-9]+$');
  static final RegExp _endsWithDigit = RegExp(r'[0-9]$');
  static final RegExp _hasDigit = RegExp('[0-9]');

  /// The WPX prefix of [call], or null if it has none.
  static String? of(String call) {
    final text = call.trim().toUpperCase();
    if (text.isEmpty || text.length > 20) return null;
    final parts = text.split('/');
    if (parts.any((p) => p.isEmpty || !_valid.hasMatch(p))) return null;

    // Drop operating suffixes (never the first part).
    var kept = [
      parts.first,
      ...parts
          .skip(1)
          .where(
            (p) =>
                !Callsign.operatingSuffixes.contains(p) &&
                !_licenceClass.contains(p),
          ),
    ];
    // A trailing single digit replaces the prefix digit.
    String? digit;
    if (kept.length > 1 &&
        kept.last.length == 1 &&
        _hasDigit.hasMatch(kept.last)) {
      digit = kept.last;
      kept = kept.sublist(0, kept.length - 1);
    }
    String? prefix;
    switch (kept.length) {
      case 1:
        prefix = _plain(kept.single);
      case 2:
        final (first, second) = (kept[0], kept[1]);
        final firstIsCall = _isCall(first);
        final secondIsCall = _isCall(second);
        final prefixPart =
            firstIsCall || (!secondIsCall && first.length >= second.length)
            ? second
            : first;
        prefix = _endsWithDigit.hasMatch(prefixPart)
            ? prefixPart
            : '${prefixPart}0';
      default:
        return null;
    }
    if (prefix == null) return null;
    if (digit != null) {
      prefix = _lastDigits.hasMatch(prefix)
          ? prefix.replaceFirst(_lastDigits, digit)
          : '$prefix$digit';
    }
    return prefix;
  }

  static bool _isCall(String part) =>
      part.length >= 3 && _callLike.hasMatch(part);

  /// The prefix of a call without any slash.
  static String? _plain(String call) {
    final m = _split.firstMatch(call);
    if (m != null) return m[1];
    if (_hasDigit.hasMatch(call)) return call; // ends with a digit
    return call.length >= 2 ? '${call.substring(0, 2)}0' : null;
  }
}
