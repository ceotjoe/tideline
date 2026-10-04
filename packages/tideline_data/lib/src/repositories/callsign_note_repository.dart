import 'package:drift/drift.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The user's own notes about stations ("always calls on 40 m at 6 UTC").
///
/// One note per home call (`EA8/DL1ABC/P` and `DL1ABC` share it), across all
/// accounts. Local only: Wavelog's API v2 has no notes resource, so nothing
/// is sent or read (docs/architecture/wavelog-api.md). Rows carry a UUID, a
/// hybrid-clock stamp, the device and a tombstone, like every row that may
/// sync between devices later.
class CallsignNoteRepository {
  /// Creates the repository.
  new(this._db, this._clock, {int Function()? nowMillis})
    : _now = nowMillis ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  final TidelineDatabase _db;
  final HlcClock _clock;
  final int Function() _now;

  /// Longest note, in characters.
  static const int maxLength = 2000;

  /// The key a note of [call] is stored under, or null if [call] has no home
  /// call.
  static String? keyOf(String call) => Callsign.tryParse(call)?.baseCall;

  SimpleSelectStatement<$CallsignNotesTable, CallsignNoteRow> _live(
    String key,
  ) =>
      _db.select(_db.callsignNotes)
        ..where((n) => n.call.equals(key) & n.deletedAt.isNull());

  /// The note of [call], or null.
  Future<String?> find(String call) async {
    final key = keyOf(call);
    if (key == null) return null;
    return (await _live(key).getSingleOrNull())?.body;
  }

  /// The note of [call] as a stream.
  Stream<String?> watch(String call) {
    final key = keyOf(call);
    if (key == null) return Stream.value(null);
    return _live(key).watchSingleOrNull().map((r) => r?.body);
  }

  /// The home calls that have a note.
  Stream<Set<String>> watchCalls() =>
      (_db.select(_db.callsignNotes)..where((n) => n.deletedAt.isNull()))
          .watch()
          .map((rows) => {for (final r in rows) r.call});

  /// Saves [body] as the note of [call]; an empty text removes the note.
  /// Throws [ArgumentError] for a [call] without a home call or a note longer
  /// than [maxLength].
  Future<void> save(String call, String body) async {
    final key = keyOf(call);
    if (key == null) throw ArgumentError.value(call, 'call', 'not a callsign');
    final text = body.trim();
    if (text.isEmpty) {
      await delete(call);
      return;
    }
    if (text.length > maxLength) {
      throw ArgumentError.value(body.length, 'body', 'too long');
    }
    await _db.transaction(() async {
      final hlc = _clock.now().toString();
      final existing = await (_db.select(
        _db.callsignNotes,
      )..where((n) => n.call.equals(key))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.callsignNotes)
            .insert(
              CallsignNotesCompanion.insert(
                id: newUuidV4(),
                call: key,
                body: text,
                originDeviceId: _clock.deviceId,
                hlcCreated: hlc,
                hlcModified: hlc,
              ),
            );
      } else {
        await (_db.update(
          _db.callsignNotes,
        )..where((n) => n.id.equals(existing.id))).write(
          CallsignNotesCompanion(
            body: Value(text),
            hlcModified: Value(hlc),
            rev: Value(existing.rev + 1),
            deletedAt: const Value(null),
          ),
        );
      }
    });
  }

  /// Removes the note of [call]. The row stays as a tombstone without its
  /// text.
  Future<void> delete(String call) async {
    final key = keyOf(call);
    if (key == null) return;
    await _db.transaction(() async {
      final existing = await _live(key).getSingleOrNull();
      if (existing == null) return;
      await (_db.update(
        _db.callsignNotes,
      )..where((n) => n.id.equals(existing.id))).write(
        CallsignNotesCompanion(
          body: const Value(''),
          hlcModified: Value(_clock.now().toString()),
          rev: Value(existing.rev + 1),
          deletedAt: Value(_now()),
        ),
      );
    });
  }
}
