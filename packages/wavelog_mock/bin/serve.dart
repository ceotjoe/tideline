// Runs the mock Wavelog API v2 for manual end-to-end testing.
//
//   dart run wavelog_mock:serve [port] [--lan]
//
// Without --lan only this computer can connect (127.0.0.1). With --lan the
// server listens on all network interfaces, so a phone or tablet in the same
// network can reach it at http://<this computer's address>:<port>. The
// address is printed. It speaks plain HTTP and its token is public: use it
// only on a network you trust, and stop it when you are done.
//
// Token: wl2_demo_token (all scopes). Station: id 3 "Home" DO1HOZ.
// Prints every request and the stored QSOs. Never expose this server.

import 'dart:async';
import 'dart:io';

import 'package:wavelog_mock/wavelog_mock.dart';

Future<void> main(List<String> args) async {
  final lan = args.contains('--lan');
  final numbers = args.where((a) => !a.startsWith('--'));
  final port = numbers.isEmpty ? 8765 : int.parse(numbers.first);
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
  await server.start(port: port, address: lan ? InternetAddress.anyIPv4 : null);
  stdout.writeln('Mock Wavelog on ${server.baseUri} (token wl2_demo_token)');
  if (lan) {
    stdout.writeln('Listening on all interfaces. From another device use:');
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final i in interfaces) {
      for (final a in i.addresses) {
        stdout.writeln(
          '  http://${a.address}:${server.baseUri.port}   (${i.name})',
        );
      }
    }
    stdout.writeln(
      'Plain HTTP, public token: only on a network you trust. Ctrl+C stops it.',
    );
  }
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
