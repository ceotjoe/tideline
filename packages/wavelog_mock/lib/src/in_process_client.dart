import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;

/// An [http.Client] that answers from a shelf [handler] in the same process.
///
/// No socket is opened. Requests to a host other than [host] fail with a
/// [http.ClientException], so a client built for one host can never reach
/// another.
class InProcessClient extends http.BaseClient {
  /// Serves [host] from [handler].
  new({required this.host, required this.handler});

  /// The only host this client answers for.
  final String host;

  /// Answers the requests.
  final shelf.Handler handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.host != host) {
      throw http.ClientException(
        'No route to ${request.url.host}',
        request.url,
      );
    }
    final response = await handler(
      shelf.Request(
        request.method,
        request.url,
        headers: request.headers,
        body: request.finalize(),
      ),
    );
    return http.StreamedResponse(
      response.read(),
      response.statusCode,
      headers: response.headers,
      request: request,
      contentLength: response.contentLength,
    );
  }
}
