import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

void main() {
  final client = demoHttpClient();
  final headers = {'authorization': 'Bearer $demoToken'};
  const base = 'https://$demoHost/index.php/api/v2';

  test('answers the status request without a token', () async {
    final response = await client.get(Uri.parse('$base/status'));
    expect(response.statusCode, 200);
  });

  test('lists the demo station and stores a QSO', () async {
    final stations = await client.get(
      Uri.parse('$base/station'),
      headers: headers,
    );
    final data = (jsonDecode(stations.body) as Map)['data'] as List;
    expect(data, hasLength(1));

    final created = await client.post(
      Uri.parse('$base/qso'),
      headers: {...headers, 'content-type': 'application/json'},
      body: jsonEncode({
        'station_profile_id': 3,
        'call': 'DL1ABC',
        'band': '20m',
        'mode': 'SSB',
        'qso_date': '2026-10-05',
        'time_on': '1200',
      }),
    );
    expect(created.statusCode, 201);
  });

  test('rejects a wrong token', () async {
    final response = await client.get(
      Uri.parse('$base/station'),
      headers: {'authorization': 'Bearer wl2_nope'},
    );
    expect(response.statusCode, 401);
  });

  test('refuses every other host', () async {
    expect(
      client.get(
        Uri.parse('https://wavelog.example.org/index.php/api/v2/status'),
      ),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('only the reserved host counts as demo', () {
    expect(isDemoHost(demoHost), isTrue);
    expect(isDemoHost('wavelog.example.org'), isFalse);
    expect(isDemoHost(null), isFalse);
  });
}
