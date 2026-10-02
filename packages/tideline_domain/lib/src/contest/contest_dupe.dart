import 'package:meta/meta.dart';
import 'package:tideline_domain/src/contest/contest_definition.dart';
import 'package:tideline_domain/src/contest/mode_category.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/mode.dart';

/// A contact as far as dupe checking is concerned.
///
/// Calls are compared upper-cased as typed: `DL1ABC` and `DL1ABC/P` are
/// different calls, as in most contests (some rules treat them as one; that
/// is not modelled).
@immutable
final class ContestContact {
  /// Creates a contact; [call] is trimmed and upper-cased.
  new({
    required this.id,
    required String call,
    required this.band,
    required this.mode,
  }) : call = normalizeCall(call);

  /// Trims and upper-cases [call].
  static String normalizeCall(String call) => call.trim().toUpperCase();

  /// The QSO id (to exclude it when editing).
  final String id;

  /// Normalised callsign.
  final String call;

  /// The band.
  final Band band;

  /// The mode.
  final Mode mode;

  /// The mode category.
  ModeCategory get category => ModeCategory.of(mode);
}

/// The outcome of a dupe check.
@immutable
final class DupeResult {
  /// Creates a result.
  const new({required this.isDupe, required this.previous});

  /// Whether a contact with the same call and the same dupe slot exists.
  final bool isDupe;

  /// Every earlier contact with this call (dupe or not), in insertion order.
  final List<ContestContact> previous;

  /// Bands the call was already worked on, lowest first, without repeats.
  List<Band> get workedBands {
    final bands = {for (final c in previous) c.band};
    return [
      for (final b in Band.all)
        if (bands.contains(b)) b,
    ];
  }

  /// Modes (ADIF main modes) the call was already worked in, in order of
  /// first contact.
  List<String> get workedModes => [
    ...{for (final c in previous) c.mode.mode},
  ];

  /// Mode categories the call was already worked in, in order of first
  /// contact.
  List<ModeCategory> get workedCategories => [
    ...{for (final c in previous) c.category},
  ];
}

/// Checks candidates against the contacts of a session, incrementally.
final class ContestDupeChecker {
  /// Creates a checker for [definition], optionally seeded with [contacts].
  new(this.definition, [Iterable<ContestContact> contacts = const []]) {
    contacts.forEach(add);
  }

  /// The dupe rule's definition.
  final ContestDefinition definition;

  final Map<String, List<ContestContact>> _byCall = {};
  final Map<String, ContestContact> _byId = {};

  /// Adds (or replaces, by id) a contact.
  void add(ContestContact contact) {
    remove(contact.id);
    _byId[contact.id] = contact;
    (_byCall[contact.call] ??= []).add(contact);
  }

  /// Removes the contact with [id], if present.
  void remove(String id) {
    final old = _byId.remove(id);
    if (old == null) return;
    final list = _byCall[old.call]!..removeWhere((c) => c.id == id);
    if (list.isEmpty) _byCall.remove(old.call);
  }

  /// Number of contacts held.
  int get length => _byId.length;

  /// Checks a candidate; [excludeId] is ignored (the QSO being edited).
  DupeResult check({
    required String call,
    required Band band,
    required Mode mode,
    String? excludeId,
  }) {
    final key = ContestContact.normalizeCall(call);
    final previous = [
      for (final c in _byCall[key] ?? const <ContestContact>[])
        if (c.id != excludeId) c,
    ];
    final slot = definition.dupe.slotKey(band, mode);
    final isDupe = previous.any(
      (c) => definition.dupe.slotKey(c.band, c.mode) == slot,
    );
    return DupeResult(isDupe: isDupe, previous: List.unmodifiable(previous));
  }
}
