import 'package:tideline_data/src/database/tideline_database.dart';

/// Key/value settings stored in the encrypted database.
///
/// Values are plain strings; typed mapping happens in the app layer.
class SettingsStore {
  /// Creates a store on top of [_db].
  new(this._db);

  final TidelineDatabase _db;

  /// All settings, updated whenever any of them changes.
  Stream<Map<String, String>> watchAll() => _db
      .select(_db.settings)
      .watch()
      .map((rows) => {for (final r in rows) r.key: r.value});

  /// All settings, once.
  Future<Map<String, String>> readAll() async {
    final rows = await _db.select(_db.settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  /// Stores [value] under [key], or removes the key when [value] is null.
  Future<void> write(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
      return;
    }
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }
}
