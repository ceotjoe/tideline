import 'package:drift/drift.dart';
import 'package:tideline_data/src/database/tideline_database.dart';

/// A user override of a command's keyboard shortcut.
typedef ShortcutOverride = ({
  String commandId,
  String platform,
  String binding,
});

/// Persists user overrides of keyboard shortcuts. Defaults live in code.
class ShortcutBindingStore {
  /// Creates a store on top of [_db].
  new(this._db);

  final TidelineDatabase _db;

  /// All overrides, updated on change.
  Stream<List<ShortcutOverride>> watchAll() => _db
      .select(_db.shortcutBindings)
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            (commandId: r.commandId, platform: r.platform, binding: r.binding),
        ],
      );

  /// Sets an override. An empty `binding` unbinds the command.
  Future<void> put(ShortcutOverride override) => _db
      .into(_db.shortcutBindings)
      .insertOnConflictUpdate(
        ShortcutBindingsCompanion.insert(
          commandId: override.commandId,
          platform: override.platform,
          binding: override.binding,
        ),
      );

  /// Removes the override, restoring the default.
  Future<void> reset(String commandId, String platform) =>
      (_db.delete(_db.shortcutBindings)..where(
            (b) => b.commandId.equals(commandId) & b.platform.equals(platform),
          ))
          .go();
}
