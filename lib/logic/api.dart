import 'package:http/http.dart';

const apiUrl = 'http://localhost:8080/generate';

class WhisperApi {
  static Future<String> generateCaptions(String id) async {
    final uri = Uri.parse(apiUrl).replace(queryParameters: {
      'link': 'https://youtube.com/watch?v=$id'
    });
    final response = await get(uri);
    return response.body;
  }
}