/// Frequency helpers. Tideline stores frequencies as integer hertz; ADIF
/// uses MHz with a decimal point and Wavelog's JSON API uses hertz.
abstract final class Frequency {
  /// Parses an ADIF FREQ value (MHz, e.g. `14.074` or `.1365`) to hertz.
  /// Returns null if malformed or not positive.
  static int? fromAdifMhz(String value) {
    final match = RegExp(r'^\s*(\d*)(?:\.(\d*))?\s*$').firstMatch(value);
    if (match == null) return null;
    final whole = match[1]!;
    final fraction = match[2] ?? '';
    if (whole.isEmpty && fraction.isEmpty) return null;
    // Sub-hertz digits beyond the sixth decimal are truncated.
    final hz =
        int.parse(whole.isEmpty ? '0' : whole) * 1000000 +
        int.parse(fraction.padRight(6, '0').substring(0, 6));
    return hz > 0 ? hz : null;
  }

  /// Formats [hz] as an ADIF FREQ value in MHz without floating-point
  /// rounding, trimming trailing zeros (14074000 → `14.074`).
  static String toAdifMhz(int hz) {
    final mhz = hz ~/ 1000000;
    final rest = (hz % 1000000).toString().padLeft(6, '0');
    final trimmed = rest.replaceFirst(RegExp(r'0+$'), '');
    return trimmed.isEmpty ? '$mhz' : '$mhz.$trimmed';
  }

  /// Interprets what an operator types: with a decimal point it is MHz
  /// (`14.074`, `144.300`); a whole number of 1800 or more is kHz
  /// (`14074`, `144300`); smaller whole numbers are MHz (`7`, `50`).
  static int? parseUserInput(String input) {
    final text = input.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    if (text.contains('.')) return fromAdifMhz(text);
    final value = int.tryParse(text);
    if (value == null || value <= 0) return null;
    return value >= 1800 ? value * 1000 : value * 1000000;
  }
}
