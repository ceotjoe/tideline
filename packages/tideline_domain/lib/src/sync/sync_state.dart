/// Where a QSO is in the upload process for one account.
///
/// See `docs/architecture/sync-state-machine.md`. The stored [name] values are
/// part of the database format: never rename them without a migration.
enum SyncState {
  /// Saved on this device only; something is missing before it can upload.
  local,

  /// Waiting for the next sync run.
  queued,

  /// A request for this QSO is in flight.
  uploading,

  /// The last attempt's outcome is unknown; reconcile before retrying.
  verifying,

  /// On the server, with the server id known.
  synced,

  /// Changed locally in a way the server cannot accept automatically.
  conflict,

  /// Refused by the server; the user must fix the QSO.
  rejected,

  /// Waiting for the user to fix the account (for example, a revoked token).
  blocked;

  /// Whether the QSO still counts towards the "waiting to sync" tide level.
  bool get isPending => this != synced;
}

/// What the sync engine has to do for a QSO in a non-synced state.
///
/// Stored by [name]; never rename values without a migration.
enum SyncOperation {
  /// Create the QSO on the server.
  create,

  /// Update patchable fields of an existing server QSO.
  patch,

  /// Delete the QSO on the server.
  delete,

  /// Delete and re-create, for changes to read-only server fields.
  replace,
}
