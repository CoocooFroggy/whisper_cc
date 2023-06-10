import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

const apiUrl = 'http://localhost:8080/generate';

class WhisperApi {
  static Future<String> generateCaptionsHuggingFace(String url) async {
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
        channel.sink.add('{"fn_index": 4,"session_hash": "axs96bihraf"}');
        continue;
      }
      if (json['msg'] == 'send_data') {
        channel.sink.add(jsonEncode({
          "data": [url, "transcribe", true],
          "event_data": null,
          "fn_index": 4,
          "session_hash": "axs96bihraf"
        }));
        continue;
      }
      if (json['msg'] == 'process_completed') {
        final output = json['output']['data'][1];
        final timestampRegex = RegExp(
            r'^\[((?:\d{2}:)?\d{2}:\d{2}\.\d{3}) -> ((?:\d{2}:)?\d{2}:\d{2}\.\d{3})\] {2}(.*)$',
            multiLine: true);

        StringBuffer buffer = StringBuffer();

        int counter = 1;
        for (var match in timestampRegex.allMatches(output)) {
          // EG 59:31.000, missing the 00: in front for hours
          String time1 = match.group(1)!;
          String time2 = match.group(2)!;

          if (time1.length == 9) {
            time1 = '00:$time1';
          }
          if (time2.length == 9) {
            time2 = '00:$time2';
          }

          // Change HH:MM:SS.MMM to HH:MM:SS,MMM
          time1 = time1.replaceFirst('.', ',');
          time2 = time2.replaceFirst('.', ',');

          buffer
            ..writeln(counter)
            ..writeln('$time1 --> $time2')
            ..writeln(match.group(3)!)
            ..writeln();

          counter++;
        }

        channel.sink.close();
        return buffer.toString();
      }
    }
    return '';
  }
}
