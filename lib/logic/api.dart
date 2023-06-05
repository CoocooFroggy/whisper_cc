import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:replicate/replicate.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whisper_cc/logic/cors_bypass.dart';
import 'package:whisper_cc/logic/subtitles.dart';
import 'package:whisper_cc/objects/segment.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

const apiUrl = 'http://localhost:8080/generate';

class WhisperApi {
  static Future<String> generateCaptionsBackend(String url) async {
    final uri = Uri.parse(apiUrl).replace(queryParameters: {'link': url});
    final response = await get(uri);
    return response.body;
  }

  static Future<String> generateCaptionsReplicate(String url) async {
    // Connect to Replicate API
    // Warning: Hard-coded
    Replicate.apiKey = 'r8_JKdmngjyc2DLzSy2LH7eVdxwPWk1pvP3ZQMiS';

    YoutubeExplode yt = YoutubeExplode();
    if (kIsWeb) {
      yt = YoutubeExplode(YoutubeHttpClient(CorsBypassClient()));
    }

    Video video = await yt.videos.get(url);
    StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(video.id);

    // Get the best m4a
    final bestStream = manifest.audioOnly.where((stream) {
      return stream.container.name == 'mp4';
    }).withHighestBitrate();

    print('Creating prediction...');
    Prediction prediction = await Replicate.instance.predictions.create(
      version:
          '91ee9c0c3df30478510ff8c8a3a545add1ad0259ad3a9f78fba57fbc05ee64f7',
      input: {
        'audio': bestStream.url.toString(),
      },
    );

    print('Polling ${prediction.id}...');

    Map<String, dynamic> output = {};
    await for (prediction in Replicate.instance.predictions
        .snapshots(id: prediction.id, shouldTriggerOnlyStatusChanges: false)) {
      print(prediction.status);

      if (prediction.status != PredictionStatus.starting) {
        print(prediction.logs);
      }

      if (prediction.status == PredictionStatus.succeeded) {
        print(prediction.output);
        // DEBUG
        print(jsonEncode(prediction.output));
        output = prediction.output;
      }

      if (prediction.status == PredictionStatus.failed ||
          prediction.status == PredictionStatus.canceled) {
        print(prediction.output);
        return '';
      }
    }

    if (output == {}) {
      return '';
    }

    List<dynamic> segmentsJson = output['segments'];
    List<Segment> segments =
        segmentsJson.map((e) => Segment.fromJson(e)).toList();

    final srt = Subtitles.generateSubtitles(segments);
    print(srt);
    return srt;
  }

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

        return buffer.toString();
      }
    }
    return '';
  }
}
