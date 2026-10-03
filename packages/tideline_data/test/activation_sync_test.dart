import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

const _token = 'wl2_activation_token';
const _scopes = {'qso:read', 'qso:write', 'station:read'};

/// What the sync of activation QSOs does against a server that behaves like
/// Wavelog: the own references and grid come from the station location.
void main() {
  late MockWavelog server;
  late TidelineDatabase db;
  late AccountRepository accounts;
  late QsoRepository qsos;
  late ActivationRepository activations;
  late SyncEngine engine;
  late String accountId;

  StationProfile station(List<StationProfile> all, int remoteId) =>
      all.singleWhere((s) => s.remoteId == remoteId);

  setUp(() async {
    server = MockWavelog(
      tokens: {_token: const MockToken(scopes: _scopes)},
      stations: [
        {'id': 3, 'name': 'Home', 'callsign': 'DO1HOZ', 'active': true},
        {
          'id': 4,
          'name': 'Acadia',
          'callsign': 'DO1HOZ',
          'gridsquare': 'FN54vh',
          'pota': 'US-0001',
          'sota': '',
          'active': false,
        },
      ],
    );
    await server.start();
    addTearDown(server.stop);
    db = await openTestDatabase();
    final machine = SyncMachine(random: Random(1));
    qsos = QsoRepository(db, HlcClock('dev-1'), machine);
    accounts = AccountRepository(db, MemorySecretStore());
    activations = ActivationRepository(db, HlcClock('dev-1'), qsos);
    final httpClient = http.Client();
    addTearDown(httpClient.close);
    engine = SyncEngine(
      qsos: qsos,
      accounts: accounts,
      journal: SyncJournalRepository(db),
      machine: machine,
      clientFor: (account, token) => WavelogClient(
        endpoint: WavelogEndpoint(server.baseUri, usesIndexPhp: true),
        token: token,
        httpClient: httpClient,
        timeout: const Duration(seconds: 5),
      ),
    );
    accountId = await accounts.add(
      label: 'Home',
      baseUrl: server.baseUri.toString(),
      usesIndexPhp: true,
      token: _token,
      scopes: _scopes,
      hasContestSessions: false,
      nowMillis: 0,
    );
  });

  Qso qso(String call, String stationId, {Map<String, String>? fields}) => Qso(
    id: newUuidV4(),
    accountId: accountId,
    stationProfileId: stationId,
    call: Callsign.tryParse(call)!,
    timeOn: UtcDateTime(DateTime.utc(2026, 10, 3, 12, call.length)),
    band: Band.tryParse('20m')!,
    mode: Mode.tryParse('SSB')!,
    fields: fields ?? const {},
  );

  test('a sync caches the references of the station locations', () async {
    await engine.sync(accountId);
    final all = await accounts.watchStations(accountId).first;
    final park = station(all, 4);
    expect(park.references.pota, 'US-0001');
    expect(park.references.sota, isNull, reason: 'empty means none');
    expect(park.references.matches(ReferenceProgram.pota, ' us-0001 '), isTrue);
    expect(park.references.matches(ReferenceProgram.sota, 'US-0001'), isFalse);
    expect(park.references.matches(ReferenceProgram.wwff, 'US-0001'), isFalse);
    expect(station(all, 3).references.pota, isNull);
    expect(
      station(all, 3).references.matches(ReferenceProgram.pota, ''),
      isFalse,
    );
  });

  test(
    'Wavelog takes the own references from the location, not the QSO',
    () async {
      await engine.sync(accountId); // caches the stations
      final all = await accounts.watchStations(accountId).first;
      final home = station(all, 3);
      final park = station(all, 4);

      final activation = await activations.start(
        accountId: accountId,
        program: ReferenceProgram.pota,
        reference: 'US-0001',
        myGridsquare: 'FN54vh',
        stationProfileId: home.id,
      );
      // Logged under Home, which has no park: the activation reference is only
      // local. The other station's reference (park to park) does travel.
      final a = await activations.logQso(
        qso('K1ABC', home.id, fields: {'POTA_REF': 'US-0002'}),
        activationId: activation.id,
      );
      // Logged under the location that carries the park.
      final b = await activations.logQso(
        qso('K1ABCD', park.id),
        activationId: activation.id,
      );
      await engine.sync(accountId);

      final sa =
          server.qsos[(await qsos.readStatus(a.id, accountId))!.remoteQsoId]!;
      final sb =
          server.qsos[(await qsos.readStatus(b.id, accountId))!.remoteQsoId]!;
      expect(a.fields['MY_POTA_REF'], 'US-0001', reason: 'kept locally');
      expect(sa.fields['pota_ref'], 'US-0002');
      expect(sa.fields.containsKey('my_pota_ref'), isFalse);
      expect(sa.fields.containsKey('my_gridsquare'), isFalse);
      expect(sb.fields['my_pota_ref'], 'US-0001');
      expect(sb.fields['my_gridsquare'], 'FN54VH');
    },
  );
}
