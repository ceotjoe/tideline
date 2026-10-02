import 'package:tideline_domain/src/values/mode.dart';

/// The coarse mode groups contests use.
enum ModeCategory {
  /// Morse code.
  cw('CW'),

  /// SSB, AM, FM and digital voice.
  phone('PHONE'),

  /// Every other (digital) mode: RTTY, FT8, PSK, …
  digi('DIGI');

  new(this.jsonName);

  /// The name used in contest definitions and Cabrillo.
  final String jsonName;

  /// The category with [jsonName] `name` (exact, upper case), or null.
  static ModeCategory? tryParse(String name) {
    for (final c in values) {
      if (c.jsonName == name) return c;
    }
    return null;
  }

  /// The category of [mode]: `CW` is CW; `SSB`, `AM`, `FM` and `DIGITALVOICE`
  /// are phone; everything else is digital.
  static ModeCategory of(Mode mode) => switch (mode.mode) {
    'CW' => cw,
    'SSB' || 'AM' || 'FM' || 'DIGITALVOICE' => phone,
    _ => digi,
  };
}
