import 'dart:math';

import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/memory_secret_store.dart';

void main() {
  group('DatabaseKeyManager', () {
    test('creates a 256-bit hex key on first launch', () async {
      final store = MemorySecretStore();
      final key = await DatabaseKeyManager(store)
          .obtainKey(databaseExists: false);
      expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(store.values[SecretKeys.databaseKey], key);
    });

    test('returns the same key afterwards', () async {
      final store = MemorySecretStore();
      final manager = DatabaseKeyManager(store);
      final first = await manager.obtainKey(databaseExists: false);
      expect(await manager.obtainKey(databaseExists: true), first);
    });

    test('never replaces a missing key for an existing database', () async {
      final store = MemorySecretStore();
      await expectLater(
        DatabaseKeyManager(store).obtainKey(databaseExists: true),
        throwsA(isA<DatabaseKeyMissingException>()),
      );
      expect(store.values, isEmpty);
    });

    test('fails if the store does not persist the key', () async {
      final store = MemorySecretStore()..dropWrites = true;
      await expectLater(
        DatabaseKeyManager(store).obtainKey(databaseExists: false),
        throwsStateError,
      );
    });

    test('keys differ between installations', () async {
      final a = await DatabaseKeyManager(
        MemorySecretStore(),
        random: Random(1),
      ).obtainKey(databaseExists: false);
      final b = await DatabaseKeyManager(
        MemorySecretStore(),
        random: Random(2),
      ).obtainKey(databaseExists: false);
      expect(a, isNot(b));
    });
  });

  group('DeviceIdProvider', () {
    test('is stable', () async {
      final store = MemorySecretStore();
      final id = await DeviceIdProvider(store).obtain();
      expect(isUuid(id), isTrue);
      expect(await DeviceIdProvider(store).obtain(), id);
    });
  });
}
