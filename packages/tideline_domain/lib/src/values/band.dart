import 'package:meta/meta.dart';
import 'package:tideline_domain/src/adif/adif_enums.g.dart';

/// An amateur radio band from the ADIF Band enumeration.
@immutable
final class Band {
  const new _(this.name, this.lowerHz, this.upperHz);

  /// The band named [name] (case-insensitive, e.g. `20m`, `70CM`), or null.
  static Band? tryParse(String name) => _byName[name.trim().toLowerCase()];

  /// The band containing [hz], or null if outside every amateur band.
  static Band? forFrequency(int hz) {
    for (final band in all) {
      if (hz >= band.lowerHz && hz <= band.upperHz) return band;
    }
    return null;
  }

  /// Every ADIF band, lowest first.
  static final List<Band> all = [
    for (final (name, lo, hi) in adifBandTable) Band._(name, lo, hi),
  ];

  static final Map<String, Band> _byName = {
    for (final b in all) b.name.toLowerCase(): b,
  };

  /// ADIF name, e.g. `20m`.
  final String name;

  /// Lower edge in hertz (inclusive).
  final int lowerHz;

  /// Upper edge in hertz (inclusive).
  final int upperHz;

  /// Whether [hz] lies within this band.
  bool contains(int hz) => hz >= lowerHz && hz <= upperHz;

  /// The next band up, or null for the highest.
  Band? get next {
    final i = all.indexOf(this);
    return i + 1 < all.length ? all[i + 1] : null;
  }

  /// The next band down, or null for the lowest.
  Band? get previous {
    final i = all.indexOf(this);
    return i > 0 ? all[i - 1] : null;
  }

  @override
  bool operator ==(Object other) => other is Band && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
