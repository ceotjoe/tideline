import 'dart:math';

import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A contest with a sent serial number (STX) and a received one.
const serialContestJson = '''
{
  "schema": 1, "id": "test-serial", "version": 1, "name": "Test Serial",
  "cabrillo": "TEST", "adif": "TEST-SERIAL",
  "modes": ["CW", "PHONE"], "bands": ["20m", "40m"],
  "exchange": {
    "sent": [{"kind": "rst"}, {"kind": "serial"}],
    "rcvd": [{"kind": "rst"}, {"kind": "serial"}]
  },
  "dupe": {"per": ["band"]},
  "points": [{"points": 1}],
  "score": "points"
}''';

/// A contest without a serial and without an ADIF contest name.
const zoneContestJson = '''
{
  "schema": 1, "id": "test-zone", "version": 1, "name": "Test Zone",
  "modes": ["CW"], "bands": ["20m"],
  "exchange": {
    "sent": [{"kind": "rst"}, {"kind": "cqZone", "default": "14"}],
    "rcvd": [{"kind": "rst"}, {"kind": "cqZone"}]
  },
  "dupe": {"per": []},
  "points": [{"points": 1}],
  "score": "points"
}''';

/// Same as [zoneContestJson] with an ADIF name.
String zoneContestWithAdif({int version = 1, String id = 'test-zone'}) =>
    zoneContestJson
        .replaceAll('"test-zone"', '"$id"')
        .replaceAll('"version": 1', '"version": $version')
        .replaceAll('"modes"', '"adif": "TEST-ZONE", "modes"');

const me = ContestStation(call: 'DO1HOZ');

/// Repositories on one fresh database with account `acc`.
class ContestHarness {
  new _(this.db, this.qsos, this.sessions, this.definitions);

  static Future<ContestHarness> create(TidelineDatabase db) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'acc',
            label: 'Home',
            baseUrl: 'https://log.example.org',
            createdAt: 0,
          ),
        );
    final qsos = QsoRepository(
      db,
      HlcClock('dev'),
      SyncMachine(random: Random(1)),
      nowMillis: () => 5000,
    );
    final definitions = ContestDefinitionRepository(db);
    await definitions.seedBuiltins([serialContestJson, zoneContestJson]);
    return ContestHarness._(
      db,
      qsos,
      ContestSessionRepository(
        db,
        HlcClock('dev'),
        qsos,
        nowMillis: () => 5000,
      ),
      definitions,
    );
  }

  final TidelineDatabase db;
  final QsoRepository qsos;
  final ContestSessionRepository sessions;
  final ContestDefinitionRepository definitions;

  Future<ContestSession> startSerial({bool remote = true}) => sessions.start(
    accountId: 'acc',
    definitionId: 'test-serial',
    me: me,
    accountSupportsSessions: remote,
  );
}

int _n = 0;

Qso testQso({
  String call = 'DL1ABC',
  int? timeOn,
  String band = '20m',
  Map<String, String> fields = const {},
  String accountId = 'acc',
}) {
  _n++;
  return Qso(
    id: 'q-$_n-${Random().nextInt(1 << 30)}',
    accountId: accountId,
    call: Callsign.tryParse(call)!,
    timeOn: UtcDateTime.fromMillis(timeOn ?? 1000000 + _n * 60000),
    band: Band.tryParse(band)!,
    mode: Mode.tryParse('CW')!,
    fields: fields,
  );
}
