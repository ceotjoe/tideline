import 'package:drift/drift.dart';
import 'package:tideline_data/src/database/tables.dart';
import 'package:tideline_data/src/database/tideline_database.steps.dart';

part 'tideline_database.g.dart';

/// The local, encrypted Tideline database: the single source of truth for
/// the UI.
///
/// Open it with `openEncryptedExecutor` so that it is always encrypted.
@DriftDatabase(
  tables: [
    Accounts,
    StationProfiles,
    Qsos,
    QsoSync,
    SyncJournal,
    ContestDefinitions,
    ContestSessions,
    ContestLinks,
    SerialAllocations,
    Activations,
    ProgramRules,
    ReferencePacks,
    DxccEntities,
    DxccPrefixes,
    ProgramReferences,
    ScpCalls,
    WorkedBefore,
    Devices,
    PeerCursors,
    Settings,
    ShortcutBindings,
  ],
)
class TidelineDatabase extends _$TidelineDatabase {
  /// Creates the database on top of the query executor `e`.
  new(super.e);

  /// Current schema version. Every change bumps it, adds a schema dump
  /// (`tool/dump_schema.sh`) and a tested migration step.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Contest sessions: Wavelog sync state, and the QSO link table.
        await m.addColumn(
          schema.contestSessions,
          schema.contestSessions.remoteState,
        );
        await m.addColumn(
          schema.contestSessions,
          schema.contestSessions.remoteEndSynced,
        );
        await m.addColumn(
          schema.contestSessions,
          schema.contestSessions.remoteErrorKey,
        );
        await m.createTable(schema.contestLinks);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
