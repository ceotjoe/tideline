import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/commands/command.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart';

/// The open encrypted database. Overridden at startup in `main`.
final databaseProvider = Provider<TidelineDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Key/value settings store.
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStore(ref.watch(databaseProvider)),
);

/// Shortcut override store.
final shortcutBindingStoreProvider = Provider<ShortcutBindingStore>(
  (ref) => ShortcutBindingStore(ref.watch(databaseProvider)),
);

/// The user's settings, live from the database.
final appSettingsProvider = StreamProvider<AppSettings>(
  (ref) =>
      ref.watch(settingsStoreProvider).watchAll().map(AppSettings.fromStore),
);

/// Writes settings changes.
final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref.watch(settingsStoreProvider)),
);

/// Persists [AppSettings] changes; the UI updates through the DB stream.
class SettingsController {
  /// Creates a controller writing to [_store].
  new(this._store);

  final SettingsStore _store;

  /// Saves [settings].
  Future<void> save(AppSettings settings) async {
    for (final entry in settings.toStore().entries) {
      await _store.write(entry.key, entry.value);
    }
  }

  /// Makes [accountId] the account that logging, the log and the sync
  /// screen use.
  Future<void> setActiveAccount(String accountId) =>
      _store.write('account.active', accountId);
}

/// User shortcut overrides, parsed. Malformed rows are ignored.
final bindingOverridesProvider = StreamProvider<List<BindingOverride>>(
  (ref) => ref.watch(shortcutBindingStoreProvider).watchAll().map((rows) {
    final byCommand = <String, List<KeyChord>>{};
    for (final row in rows) {
      final chords = byCommand.putIfAbsent(row.commandId, () => []);
      for (final part in row.binding.split(' ')) {
        final chord = KeyChord.parse(part);
        if (chord != null) chords.add(chord);
      }
    }
    return [
      for (final e in byCommand.entries) (commandId: e.key, chords: e.value),
    ];
  }),
);

/// The command registry with the user's overrides applied.
final commandRegistryProvider = Provider<CommandRegistry>(
  (ref) => CommandRegistry(
    tidelineCommands,
    overrides: ref.watch(bindingOverridesProvider).value ?? const [],
  ),
);

/// Number of QSOs not yet synced, across accounts. Drives the tide gauge.
final pendingSyncCountProvider = StreamProvider<int>(
  (ref) =>
      SyncStatusRepository(ref.watch(databaseProvider)).watchPendingCount(),
);
