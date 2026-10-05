import 'package:http/http.dart' as http;
import 'package:wavelog_mock/src/in_process_client.dart';
import 'package:wavelog_mock/src/mock_wavelog.dart';

/// The demo server's address. `.invalid` never resolves (RFC 6761), so
/// nothing can reach a real server under this name.
const demoHost = 'demo.tideline.invalid';

/// The demo server's address as a URL.
const demoUrl = 'https://$demoHost';

/// The demo token. It is public and only valid against the demo server.
const demoToken = 'wl2_demo_token';

/// Whether [host] is the demo server.
bool isDemoHost(String? host) => host == demoHost;

MockWavelog? _demoServer;

/// The demo server: one per process, so what a reviewer uploads stays
/// visible until the app is closed.
MockWavelog get demoWavelog => _demoServer ??= MockWavelog(
  tokens: {
    demoToken: const MockToken(
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
      'name': 'Demo station',
      'callsign': 'N0CALL',
      'gridsquare': 'JO40',
      'active': true,
    },
  ],
);

/// A client that talks to the demo server without a network.
http.Client demoHttpClient() =>
    InProcessClient(host: demoHost, handler: demoWavelog.handler);
