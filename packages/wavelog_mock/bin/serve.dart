// Runs the mock Wavelog API v2 for manual end-to-end testing.
//
//   dart run wavelog_mock:serve [port]
//
// Token: wl2_demo_token (all scopes). Station: id 3 "Home" DO1HOZ.
// Prints every request and the stored QSOs. Never expose this server.

import 'dart:async';
import 'dart:io';

import 'package:wavelog_mock/wavelog_mock.dart';

Future<void> main(List<String> args) async {
  final port = args.isEmpty ? 8765 : int.parse(args.first);
  final server = MockWavelog(
    tokens: {
      'wl2_demo_token': const MockToken(
        name: 'Demo',
        scopes: {
          'qso:read',
          'qso:write',
          'qso:delete',
          'station:read',
          'contest:read',
          'contest:write',
          'contest:delete',
        },
      ),
    },
    stations: [
      {
        'id': 3,
        'name': 'Home',
        'callsign': 'DO1HOZ',
        'gridsquare': 'JO40',
        'active': true,
      },
      {'id': 4, 'name': 'Portable', 'callsign': 'DO1HOZ/P', 'active': false},
    ],
  );
  await server.start(port: port);
  stdout.writeln('Mock Wavelog on ${server.baseUri} (token wl2_demo_token)');
  var seen = 0;
  Timer.periodic(const Duration(seconds: 1), (_) {
    for (final r in server.requests.skip(seen)) {
      stdout.writeln('${r.method} ${r.path}');
    }
    seen = server.requests.length;
  });
  var known = 0;
  Timer.periodic(const Duration(seconds: 1), (_) {
    if (server.qsos.length != known) {
      known = server.qsos.length;
      stdout.writeln('QSOs on server: $known');
      for (final q in server.qsos.values) {
        stdout.writeln(
          '  #${q.id} ${q.fields['call']} ${q.fields['qso_date']} '
          '${q.fields['band']} ${q.fields['mode']}',
        );
      }
    }
  });
}
