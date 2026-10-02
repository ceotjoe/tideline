import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

const _token = 'wl2_qso_token';

void main() {
  late MockWavelog server;
  late http.Client httpClient;
  late WavelogClient client;

  setUp(() async {
    server = MockWavelog(
      tokens: {
        _token: const MockToken(
          scopes: {'qso:read', 'qso:write', 'qso:delete', 'station:read'},
        ),
      },
      stations: [
        {'id': 3, 'name': 'Home', 'callsign': 'DO1HOZ', 'active': true},
      ],
    );
    await server.start();
    httpClient = http.Client();
    client = WavelogClient(
      endpoint: WavelogEndpoint(server.baseUri, usesIndexPhp: true),
      token: _token,
      httpClient: httpClient,
      timeout: const Duration(seconds: 5),
    );
  });

  tearDown(() async {
    httpClient.close();
    await server.stop();
  });

  Map<String, Object> qso({String call = 'DL1ABC', String time = '14:05:33'}) =>
      {
        'call': call,
        'band': '20m',
        'mode': 'SSB',
        'submode': 'USB',
        'qso_date': '2026-10-02',
        'time_on': time,
        'freq': 14205000,
        'rst_sent': '59',
      };

  test('creates a QSO and returns the server id', () async {
    final id = await client.createQso(stationProfileId: 3, fields: qso());
    expect(server.qsos[id]!.fields['call'], 'DL1ABC');
  });

  test('a duplicate in the same minute is reported as such', () async {
    await client.createQso(stationProfileId: 3, fields: qso());
    await expectLater(
      client.createQso(stationProfileId: 3, fields: qso(time: '14:05:59')),
      throwsA(
        isA<WavelogValidationError>().having(
          (e) => e.isDuplicate,
          'isDuplicate',
          isTrue,
        ),
      ),
    );
    // A different minute is not a duplicate.
    await client.createQso(stationProfileId: 3, fields: qso(time: '14:06:00'));
    expect(server.qsos, hasLength(2));
  });

  test('a foreign station is forbidden', () async {
    await expectLater(
      client.createQso(stationProfileId: 99, fields: qso()),
      throwsA(isA<WavelogForbidden>()),
    );
  });

  test('finds QSOs for reconciling, across pages', () async {
    for (var m = 0; m < 3; m++) {
      await client.createQso(
        stationProfileId: 3,
        fields: qso(time: '14:0$m:00'),
      );
    }
    await client.createQso(stationProfileId: 3, fields: qso(call: 'G4XYZ'));
    final found = await client.findQsos(
      callsign: 'DL1ABC',
      since: DateTime.utc(2026, 10, 2),
      until: DateTime.utc(2026, 10, 2),
      stationId: 3,
    );
    expect(found, hasLength(3));
    expect(found.first.time.isUtc, isTrue);
    expect(found.map((q) => q.band).toSet(), {'20m'});
  });

  test('patches editable fields and deletes', () async {
    final id = await client.createQso(stationProfileId: 3, fields: qso());
    await client.patchQso(id, {'rst_rcvd': '57', 'name': 'Anna'});
    expect(server.qsos[id]!.fields['name'], 'Anna');
    await client.deleteQso(id);
    expect(server.qsos, isEmpty);
    // Deleting again is not an error.
    await client.deleteQso(id);
  });

  test(
    'a stored-then-500 create is a server error (outcome unknown)',
    () async {
      server.postQsoFaults.add(MockFault.storeThenServerError);
      await expectLater(
        client.createQso(stationProfileId: 3, fields: qso()),
        throwsA(isA<WavelogServerError>()),
      );
      expect(server.qsos, hasLength(1)); // it did reach the server
    },
  );

  test('a dropped connection is a network error', () async {
    server.postQsoFaults.add(MockFault.storeThenDropConnection);
    await expectLater(
      client.createQso(stationProfileId: 3, fields: qso()),
      throwsA(isA<WavelogNetworkError>()),
    );
    expect(server.qsos, hasLength(1));
  });

  test('dry run parses without storing', () async {
    final result = await client.dryRun(
      stationProfileId: 3,
      qsos: [
        qso(),
        qso(call: 'G4XYZ'),
      ],
    );
    expect(result.parsed, 2);
    expect(server.qsos, isEmpty);
  });
}
