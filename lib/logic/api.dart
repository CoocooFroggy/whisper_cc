import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whisper_cc/objects/backend.dart';

const apiUrl = 'http://localhost:8080/generate';

class WhisperApi {
  static Stream<BackendStatus> generateCaptionsHuggingFace(String url) async* {
    final channel = WebSocketChannel.connect(
        Uri.parse('wss://sanchit-gandhi-whisper-jax.hf.space/queue/join'));

    await for (final o in channel.stream) {
      String message = o as String;
      print(message);

      if (message == 'Ping') {
        channel.sink.add('Pong');
        continue;
      }

      final json = jsonDecode(message);

      if (json['msg'] == 'send_hash') {
        channel.sink.add('{"fn_index": 6,"session_hash": "axs96bihraf"}');
        continue;
      }
      if (json['msg'] == 'send_data') {
        channel.sink.add(jsonEncode({
          "data": [url, "transcribe", true],
          "event_data": null,
          "fn_index": 6,
          "session_hash": "axs96bihraf"
        }));
        continue;
      }
      final status = BackendStatus.fromJson(json);
      yield status;
    }
  }
}
