import 'package:http/http.dart';

const apiUrl = 'http://localhost:8080/generate';

class WhisperApi {
  static Future<String> generateCaptions(String url) async {
    final uri = Uri.parse(apiUrl).replace(queryParameters: {'link': url});
    final response = await get(uri);
    return response.body;
  }
}
