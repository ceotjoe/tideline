import 'package:meta/meta.dart';
import 'package:tideline_domain/src/contest/contest_definition_exception.dart';
import 'package:tideline_domain/src/contest/contest_json.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/mode_category.dart';
import 'package:tideline_domain/src/values/band.dart';

/// A condition over my station, their station and the QSO (the `when`
/// objects of a contest definition). All set conditions must hold.
///
/// If a condition needs data that is unknown, it does not hold.
@immutable
final class ContestPredicate {
  /// Creates a predicate. At least one condition must be set.
  const new({
    this.sameDxcc,
    this.sameContinent,
    this.sameCqZone,
    this.sameItuZone,
    this.myContinent,
    this.theirContinent,
    this.myContinentNot,
    this.theirContinentNot,
    this.myDxcc,
    this.theirDxcc,
    this.myDxccNot,
    this.theirDxccNot,
    this.modeCategory,
    this.band,
  });

  /// Parses a `when` object at [path].
  factory fromJson(Object? json, String path) {
    final map = ContestJson.object(json, path, optional: _keys);
    if (map.isEmpty) {
      ContestJson.fail(ContestDefinitionError.emptyPredicate, path);
    }
    List<T>? many<T>(String key, T Function(Object?, String) one) =>
        map.containsKey(key)
        ? ContestJson.oneOrMany(map[key], ContestJson.child(path, key), one)
        : null;
    bool? flag(String key) => map.containsKey(key)
        ? ContestJson.boolean(map[key], ContestJson.child(path, key))
        : null;

    return ContestPredicate(
      sameDxcc: flag('sameDxcc'),
      sameContinent: flag('sameContinent'),
      sameCqZone: flag('sameCqZone'),
      sameItuZone: flag('sameItuZone'),
      myContinent: many('myContinent', _continent),
      theirContinent: many('theirContinent', _continent),
      myContinentNot: many('myContinentNot', _continent),
      theirContinentNot: many('theirContinentNot', _continent),
      myDxcc: many('myDxcc', _dxcc),
      theirDxcc: many('theirDxcc', _dxcc),
      myDxccNot: many('myDxccNot', _dxcc),
      theirDxccNot: many('theirDxccNot', _dxcc),
      modeCategory: many(
        'modeCategory',
        (v, p) =>
            ContestJson.enumValue(v, p, ModeCategory.values, (c) => c.jsonName),
      ),
      band: many('band', _band),
    );
  }

  static const Set<String> _keys = {
    'sameDxcc',
    'sameContinent',
    'sameCqZone',
    'sameItuZone',
    'myContinent',
    'theirContinent',
    'myContinentNot',
    'theirContinentNot',
    'myDxcc',
    'theirDxcc',
    'myDxccNot',
    'theirDxccNot',
    'modeCategory',
    'band',
  };

  /// The valid continent codes.
  static const Set<String> continents = {
    'AF',
    'AN',
    'AS',
    'EU',
    'NA',
    'OC',
    'SA',
  };

  static String _continent(Object? v, String path) {
    final text = ContestJson.string(v, path, max: 2);
    if (!continents.contains(text)) {
      ContestJson.fail(ContestDefinitionError.unknownValue, path);
    }
    return text;
  }

  static int _dxcc(Object? v, String path) =>
      ContestJson.integer(v, path, min: 1, max: 999);

  static Band _band(Object? v, String path) {
    final text = ContestJson.string(v, path, max: 8);
    return Band.tryParse(text) ??
        ContestJson.fail(ContestDefinitionError.unknownBand, path);
  }

  /// My and their DXCC entity are (true) or are not (false) equal.
  final bool? sameDxcc;

  /// My and their continent are (true) or are not (false) equal.
  final bool? sameContinent;

  /// My and their CQ zone are (true) or are not (false) equal. Their zone is
  /// the received exchange value when there is one (see `ContestQso`).
  final bool? sameCqZone;

  /// My and their ITU zone are (true) or are not (false) equal. Their zone is
  /// the received exchange value when there is one (see `ContestQso`).
  final bool? sameItuZone;

  /// My continent is one of these.
  final List<String>? myContinent;

  /// Their continent is one of these.
  final List<String>? theirContinent;

  /// My continent is known and none of these.
  final List<String>? myContinentNot;

  /// Their continent is known and none of these.
  final List<String>? theirContinentNot;

  /// My DXCC entity is one of these.
  final List<int>? myDxcc;

  /// Their DXCC entity is one of these.
  final List<int>? theirDxcc;

  /// My DXCC entity is known and none of these.
  final List<int>? myDxccNot;

  /// Their DXCC entity is known and none of these.
  final List<int>? theirDxccNot;

  /// The QSO's mode category is one of these.
  final List<ModeCategory>? modeCategory;

  /// The QSO's band is one of these.
  final List<Band>? band;

  /// Whether only `my*` conditions are set (the rule for exchange variants).
  bool get onlyMine =>
      sameDxcc == null &&
      sameContinent == null &&
      sameCqZone == null &&
      sameItuZone == null &&
      theirContinent == null &&
      theirContinentNot == null &&
      theirDxcc == null &&
      theirDxccNot == null &&
      modeCategory == null &&
      band == null;

  /// Whether only `their*` conditions are set (the rule for received
  /// exchange elements that depend on the other station).
  bool get onlyTheirs =>
      sameDxcc == null &&
      sameContinent == null &&
      sameCqZone == null &&
      sameItuZone == null &&
      myContinent == null &&
      myContinentNot == null &&
      myDxcc == null &&
      myDxccNot == null &&
      modeCategory == null &&
      band == null;

  /// Three-valued evaluation of the `their*` conditions against [them]:
  /// true if they all hold, false if one definitely does not hold, null if
  /// none fails but a needed value is unknown. Other conditions are ignored,
  /// so use it with [onlyTheirs] predicates.
  bool? matchesTheirs(ContestStation? them) {
    var unknown = false;
    bool? one<T>(List<T>? list, T? value, {required bool negate}) {
      if (list == null) return true;
      if (value == null) {
        unknown = true;
        return true;
      }
      return list.contains(value) != negate;
    }

    final results = [
      one(theirContinent, them?.continent, negate: false),
      one(theirContinentNot, them?.continent, negate: true),
      one(theirDxcc, them?.dxcc, negate: false),
      one(theirDxccNot, them?.dxcc, negate: true),
    ];
    if (results.any((r) => r == false)) return false;
    return unknown ? null : true;
  }

  /// Whether every set condition holds.
  bool matches({
    ContestStation? me,
    ContestStation? them,
    Band? qsoBand,
    ModeCategory? category,
  }) {
    final myDx = me?.dxcc;
    final theirDx = them?.dxcc;
    final myCont = me?.continent;
    final theirCont = them?.continent;

    final sameDxccCond = sameDxcc;
    if (sameDxccCond != null) {
      if (myDx == null || theirDx == null) return false;
      if ((myDx == theirDx) != sameDxccCond) return false;
    }
    final sameContCond = sameContinent;
    if (sameContCond != null) {
      if (myCont == null || theirCont == null) return false;
      if ((myCont == theirCont) != sameContCond) return false;
    }
    final sameCqCond = sameCqZone;
    if (sameCqCond != null) {
      final mine = me?.cqz;
      final theirs = them?.cqz;
      if (mine == null || theirs == null) return false;
      if ((mine == theirs) != sameCqCond) return false;
    }
    final sameItuCond = sameItuZone;
    if (sameItuCond != null) {
      final mine = me?.ituz;
      final theirs = them?.ituz;
      if (mine == null || theirs == null) return false;
      if ((mine == theirs) != sameItuCond) return false;
    }
    final myContCond = myContinent;
    if (myContCond != null &&
        (myCont == null || !myContCond.contains(myCont))) {
      return false;
    }
    final theirContCond = theirContinent;
    if (theirContCond != null &&
        (theirCont == null || !theirContCond.contains(theirCont))) {
      return false;
    }
    final myContNot = myContinentNot;
    if (myContNot != null && (myCont == null || myContNot.contains(myCont))) {
      return false;
    }
    final theirContNot = theirContinentNot;
    if (theirContNot != null &&
        (theirCont == null || theirContNot.contains(theirCont))) {
      return false;
    }
    final myDxccNotCond = myDxccNot;
    if (myDxccNotCond != null &&
        (myDx == null || myDxccNotCond.contains(myDx))) {
      return false;
    }
    final theirDxccNotCond = theirDxccNot;
    if (theirDxccNotCond != null &&
        (theirDx == null || theirDxccNotCond.contains(theirDx))) {
      return false;
    }
    final myDxccCond = myDxcc;
    if (myDxccCond != null && (myDx == null || !myDxccCond.contains(myDx))) {
      return false;
    }
    final theirDxccCond = theirDxcc;
    if (theirDxccCond != null &&
        (theirDx == null || !theirDxccCond.contains(theirDx))) {
      return false;
    }
    final categoryCond = modeCategory;
    if (categoryCond != null &&
        (category == null || !categoryCond.contains(category))) {
      return false;
    }
    final bandCond = band;
    if (bandCond != null && (qsoBand == null || !bandCond.contains(qsoBand))) {
      return false;
    }
    return true;
  }

  /// The JSON form (single values are written bare).
  Map<String, Object?> toJson() => {
    if (sameDxcc != null) 'sameDxcc': sameDxcc,
    if (sameContinent != null) 'sameContinent': sameContinent,
    if (sameCqZone != null) 'sameCqZone': sameCqZone,
    if (sameItuZone != null) 'sameItuZone': sameItuZone,
    if (myContinent != null)
      'myContinent': ContestJson.compact(myContinent!, (v) => v),
    if (theirContinent != null)
      'theirContinent': ContestJson.compact(theirContinent!, (v) => v),
    if (myContinentNot != null)
      'myContinentNot': ContestJson.compact(myContinentNot!, (v) => v),
    if (theirContinentNot != null)
      'theirContinentNot': ContestJson.compact(theirContinentNot!, (v) => v),
    if (myDxcc != null) 'myDxcc': ContestJson.compact(myDxcc!, (v) => v),
    if (theirDxcc != null)
      'theirDxcc': ContestJson.compact(theirDxcc!, (v) => v),
    if (myDxccNot != null)
      'myDxccNot': ContestJson.compact(myDxccNot!, (v) => v),
    if (theirDxccNot != null)
      'theirDxccNot': ContestJson.compact(theirDxccNot!, (v) => v),
    if (modeCategory != null)
      'modeCategory': ContestJson.compact(modeCategory!, (v) => v.jsonName),
    if (band != null) 'band': ContestJson.compact(band!, (v) => v.name),
  };
}
