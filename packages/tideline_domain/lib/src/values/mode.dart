import 'package:meta/meta.dart';
import 'package:tideline_domain/src/adif/adif_enums.g.dart';

/// An ADIF mode with optional submode, e.g. `SSB`/`USB` or `MFSK`/`FT4`.
@immutable
final class Mode {
  const new _(this.mode, this.submode);

  /// Interprets user or import input such as `USB`, `ft4`, `CW` or
  /// `DIGITALVOICE C4FM`.
  ///
  /// Submodes and ADIF import-only modes are mapped to their parent mode,
  /// as the ADIF specification requires on export. Returns null for
  /// anything not in the ADIF Mode enumeration.
  static Mode? tryParse(String input, {String? submode}) {
    final text = input.trim().toUpperCase();
    if (text.isEmpty) return null;
    final sub = submode?.trim().toUpperCase();

    final parts = text.split(RegExp(r'\s+'));
    if (sub == null &&
        parts.length == 2 &&
        adifModeTable.containsKey(parts[0])) {
      return tryParse(parts[0], submode: parts[1]);
    }

    final subs = adifModeTable[text];
    if (subs != null) {
      if (sub == null || sub.isEmpty) return Mode._(text, null);
      return subs.contains(sub) ? Mode._(text, sub) : null;
    }
    // A submode on its own ("USB", "FT4") or an import-only mode.
    final parent = _parentOfSubmode[text];
    if (parent != null) return Mode._(parent, text);
    return null;
  }

  static final Map<String, String> _parentOfSubmode = {
    for (final MapEntry(key: mode, value: subs) in adifModeTable.entries)
      for (final s in subs) s: mode,
  };

  /// The common modes offered first in pickers.
  static final List<Mode> common = [
    for (final s in const ['SSB', 'CW', 'FM', 'AM', 'FT8', 'FT4', 'RTTY'])
      tryParse(s)!,
  ];

  /// ADIF MODE.
  final String mode;

  /// ADIF SUBMODE, or null.
  final String? submode;

  /// What operators call it: the submode if there is one (`USB`, `FT4`),
  /// otherwise the mode.
  String get label => submode ?? mode;

  /// Whether signal reports are 59-style (phone) rather than 599-style.
  bool get isPhone => const {'SSB', 'AM', 'FM', 'DIGITALVOICE'}.contains(mode);

  /// Whether reports are dB values (WSJT-X style modes).
  bool get usesDbReports =>
      const {'FT8', 'JT65', 'JT9', 'JT4', 'MSK144', 'Q65'}.contains(mode) ||
      const {'FT4', 'FST4', 'Q65', 'JS8'}.contains(submode);

  /// Default signal report for this mode.
  String get defaultReport => usesDbReports
      ? '-10'
      : isPhone
      ? '59'
      : '599';

  @override
  bool operator ==(Object other) =>
      other is Mode && other.mode == mode && other.submode == submode;

  @override
  int get hashCode => Object.hash(mode, submode);

  @override
  String toString() => submode == null ? mode : '$mode/$submode';
}
