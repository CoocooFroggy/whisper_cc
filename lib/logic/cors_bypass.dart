import 'package:http/http.dart' as http;

class CorsBypassClient extends http.BaseClient {
  final _client = http.Client();

  @override
  Future<http.StreamedResponse> send(covariant http.Request request) {
    final uri = request.url;
    final http.BaseRequest newRequest = http.Request(
        request.method,
        request.url.replace(
          //TODO: change this cors-anywhere to your instance
            host: '',
            pathSegments: [uri.host, ...uri.pathSegments]))
      ..headers.addAll({
        ...request.headers,
        'origin': 'https://www.youtube.com',
        'x-requested-with': 'https://www.youtube.com',
      })
      ..bodyBytes = request.bodyBytes;

    return _client.send(newRequest);
  }
}