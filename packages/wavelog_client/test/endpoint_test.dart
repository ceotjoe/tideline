import 'package:test/test.dart';
import 'package:wavelog_client/wavelog_client.dart';

void main() {
  group('WavelogEndpoint.parse', () {
    test('defaults to https and the index.php variant', () {
      final e = WavelogEndpoint.parse('log.example.org');
      expect(
        e.resolve('qso').toString(),
        'https://log.example.org/index.php/api/v2/qso',
      );
    });

    test('keeps sub-directory installs and strips pasted page paths', () {
      final e = WavelogEndpoint.parse(
        'https://example.org/wavelog/index.php/dashboard/',
      );
      expect(e.baseUri.toString(), 'https://example.org/wavelog');
      expect(
        e.alternative.resolve('qso', id: '7').toString(),
        'https://example.org/wavelog/api/v2/qso/7',
      );
    });

    test('encodes query parameters', () {
      final e = WavelogEndpoint.parse('https://h');
      expect(
        e.resolve('catalog', query: {'topic': 'contest'}).query,
        'topic=contest',
      );
    });

    test('rejects plain http to public hosts, even with opt-in', () {
      expect(
        () => WavelogEndpoint.parse(
          'http://log.example.org',
          allowHttpOnPrivateNetwork: true,
        ),
        throwsA(
          isA<InvalidServerUrlException>().having(
            (e) => e.reason,
            'reason',
            InvalidServerUrlReason.insecurePublicHttp,
          ),
        ),
      );
    });

    test('allows http on private networks only after opt-in', () {
      expect(
        () => WavelogEndpoint.parse('http://192.168.1.20'),
        throwsA(isA<InvalidServerUrlException>()),
      );
      expect(
        WavelogEndpoint.parse(
          'http://192.168.1.20/wavelog',
          allowHttpOnPrivateNetwork: true,
        ).baseUri.toString(),
        'http://192.168.1.20/wavelog',
      );
    });

    test('rejects credentials, queries and other schemes', () {
      for (final bad in [
        'https://user:pw@example.org',
        'https://example.org/?x=1',
        'ftp://example.org',
        'https://',
      ]) {
        expect(
          () => WavelogEndpoint.parse(bad),
          throwsA(isA<InvalidServerUrlException>()),
          reason: bad,
        );
      }
    });
  });

  group('isPrivateHost', () {
    test('classifies addresses', () {
      for (final host in [
        '10.0.0.1',
        '172.16.5.4',
        '172.31.255.255',
        '192.168.0.10',
        '127.0.0.1',
        '169.254.1.1',
        'localhost',
        'wavelog.local',
        '[::1]',
        'fd12::1',
        'fe80::1',
      ]) {
        expect(WavelogEndpoint.isPrivateHost(host), isTrue, reason: host);
      }
      for (final host in [
        '172.32.0.1',
        '8.8.8.8',
        'example.org',
        '192.169.0.1',
        '2001:db8::1',
        '999.1.1.1',
      ]) {
        expect(WavelogEndpoint.isPrivateHost(host), isFalse, reason: host);
      }
    });
  });
}
