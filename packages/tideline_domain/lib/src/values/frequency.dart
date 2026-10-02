import 'package:tideline_domain/src/values/band.dart';

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

  static const _kiloHertzThreshold = 1800;

  /// Interprets what an operator types.
  ///
  /// With a decimal point (or comma) the value is MHz (`14.074`). A whole
  /// number N is MHz if N MHz lies in an amateur band, else kHz if N kHz
  /// does (`472` is 472 kHz, `14074` is 14.074 MHz). Numbers of 1800 and up are
  /// never MHz. Outside every band the fallback is kHz from 1800 up and MHz
  /// below.
  static int? parseUserInput(String input) => interpretUserInput(input)?.hz;

  /// Like [parseUserInput], but also reports the amateur band containing the
  /// result (null when it lies outside every band).
  static ({int hz, Band? band})? interpretUserInput(String input) {
    final hz = _parse(input);
    return hz == null ? null : (hz: hz, band: Band.forFrequency(hz));
  }

  static int? _parse(String input) {
    final text = input.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    if (text.contains('.')) return fromAdifMhz(text);
    if (!RegExp(r'^\d+$').hasMatch(text)) return null;
    final value = int.tryParse(text);
    if (value == null || value <= 0) return null;
    // Guard against overflow for absurdly long digit strings.
    if (value > 1000000000000) return null;
    final asMhz = value * 1000000;
    final asKhz = value * 1000;
    // Whole numbers from 1800 up are never MHz: 144300 would otherwise be
    // 144.3 GHz and 10100 would be 10.1 GHz. Microwave users type a decimal.
    if (value < _kiloHertzThreshold && Band.forFrequency(asMhz) != null) {
      return asMhz;
    }
    if (Band.forFrequency(asKhz) != null) return asKhz;
    return value >= _kiloHertzThreshold ? asKhz : asMhz;
  }
}
