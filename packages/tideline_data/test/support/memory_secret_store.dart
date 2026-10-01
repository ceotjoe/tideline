import 'package:tideline_domain/tideline_domain.dart';

/// In-memory [SecretStore] for tests.
class MemorySecretStore implements SecretStore {
  final Map<String, String> values = {};

  /// When true, writes are silently dropped (a misbehaving keychain).
  bool dropWrites = false;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    if (!dropWrites) values[key] = value;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}
