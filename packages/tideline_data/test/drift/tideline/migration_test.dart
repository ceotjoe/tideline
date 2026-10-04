// dart format width=80
import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';
import 'package:tideline_data/src/database/tideline_database.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = TidelineDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test(
    'migration from v1 to v2 keeps data and adds contest sync state',
    () async {
      const hlc = '000000000000001-0000-dev';
      const account = v1.AccountsData(
        id: 'acc',
        label: 'Home',
        baseUrl: 'https://log.example.org',
        usesIndexPhp: 1,
        allowHttpLan: 0,
        serverCaps: '{}',
        scopes: '[]',
        createdAt: 1,
      );
      const definition = v1.ContestDefinitionsData(
        id: 'cq-ww-ssb',
        name: 'CQ WW SSB',
        version: 1,
        definition: '{}',
        builtin: 1,
      );
      const session = v1.ContestSessionsData(
        originDeviceId: 'dev',
        hlcCreated: hlc,
        hlcModified: hlc,
        rev: 3,
        id: 'sess',
        definitionId: 'cq-ww-ssb',
        accountId: 'acc',
        startedAt: 1000,
        endedAt: 2000,
        settings: '{"a":1}',
        remoteSessionId: 7,
        serialStrategy: 'single',
      );
      const allocation = v1.SerialAllocationsData(
        sessionId: 'sess',
        serial: 1,
        qsoId: 'q1',
        allocatedAt: 1500,
      );

      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: TidelineDatabase.new,
        createItems: (batch, oldDb) {
          batch
            ..insert(oldDb.accounts, account)
            ..insert(oldDb.contestDefinitions, definition)
            ..insert(oldDb.contestSessions, session)
            ..insert(oldDb.serialAllocations, allocation);
        },
        validateItems: (newDb) async {
          final sessions = await newDb.select(newDb.contestSessions).get();
          expect(sessions, hasLength(1));
          final row = sessions.single;
          expect(row.id, 'sess');
          expect(row.rev, 3);
          expect(row.endedAt, 2000);
          expect(row.settings, '{"a":1}');
          expect(row.remoteSessionId, 7);
          // New columns: existing sessions stay local.
          expect(row.remoteState, 'local');
          expect(row.remoteEndSynced, isNull);
          expect(row.remoteErrorKey, isNull);
          final allocations = await newDb.select(newDb.serialAllocations).get();
          expect(allocations.single.serial, 1);
          expect(await newDb.select(newDb.contestLinks).get(), isEmpty);
        },
      );
    },
  );

  test(
    'migration from v2 to v3 keeps references and marks them active',
    () async {
      const row = v2.ProgramReferencesData(
        program: 'POTA',
        ref: 'US-0001',
        name: 'Acadia National Park',
        region: 'US-ME',
        lat: 44.31,
        lon: -68.2034,
        validFrom: 1000,
      );
      await verifier.testWithDataIntegrity(
        oldVersion: 2,
        newVersion: 3,
        createOld: v2.DatabaseAtV2.new,
        createNew: v3.DatabaseAtV3.new,
        openTestedDatabase: TidelineDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(oldDb.programReferences, row);
        },
        validateItems: (newDb) async {
          final rows = await newDb.select(newDb.programReferences).get();
          expect(rows, hasLength(1));
          expect(rows.single.ref, 'US-0001');
          expect(rows.single.name, 'Acadia National Park');
          expect(rows.single.validFrom, 1000);
          expect(rows.single.active, 1);
        },
      );
    },
  );

  test('migration from v3 to v4 keeps the log and adds an empty directory '
      'and notes', () async {
    const hlc = '000000000000001-0000-dev';
    const account = v3.AccountsData(
      id: 'acc',
      label: 'Home',
      baseUrl: 'https://log.example.org',
      usesIndexPhp: 1,
      allowHttpLan: 0,
      serverCaps: '{}',
      scopes: '[]',
      createdAt: 1,
    );
    const qso = v3.QsosData(
      originDeviceId: 'dev',
      hlcCreated: hlc,
      hlcModified: hlc,
      rev: 1,
      id: 'q1',
      accountId: 'acc',
      call: 'DL1ABC',
      timeOn: 1000,
      band: '20m',
      mode: 'CW',
      name: 'Anna',
      adifExtra: '{}',
      source: 'manual',
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: TidelineDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insert(oldDb.accounts, account)
          ..insert(oldDb.qsos, qso);
      },
      validateItems: (newDb) async {
        final qsos = await newDb.select(newDb.qsos).get();
        expect(qsos.single.name, 'Anna');
        expect(await newDb.select(newDb.callsignDirectory).get(), isEmpty);
        expect(await newDb.select(newDb.callsignNotes).get(), isEmpty);
      },
    );
  });
}
