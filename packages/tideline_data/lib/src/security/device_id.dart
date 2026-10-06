import 'package:tideline_domain/tideline_domain.dart';

/// Provides this installation's stable device id from the [SecretStore].
class DeviceIdProvider {
  /// Creates a provider backed by the secure `store`.
  new(this._store);

  final SecretStore _store;

  /// Returns the device id, creating it on first use.
  Future<String> obtain() async {
    final existing = await _store.read(SecretKeys.deviceId);
    if (existing != null && isUuid(existing)) return existing;
    final id = newUuidV4();
    await _store.write(SecretKeys.deviceId, id);
    return id;
  }
}
