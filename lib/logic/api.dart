import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:replicate/replicate.dart';
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
      version: '91ee9c0c3df30478510ff8c8a3a545add1ad0259ad3a9f78fba57fbc05ee64f7',
      input: {
        'audio':
        bestStream.url.toString(),
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
}
