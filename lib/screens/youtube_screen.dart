import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:whisper_cc/logic/api.dart';
import 'package:whisper_cc/logic/cors_bypass.dart';
import 'package:whisper_cc/objects/backend_enum.dart';
import 'package:whisper_cc/objects/video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Quality {
  final String url, label;

  Quality({
    required this.url,
    required this.label,
  });
}

class YoutubeExamplePage extends StatefulWidget {
  const YoutubeExamplePage({Key? key}) : super(key: key);

  @override
  State<YoutubeExamplePage> createState() => _YoutubeExamplePageState();
}

class _YoutubeExamplePageState extends State<YoutubeExamplePage> {
  final _controller = MeeduPlayerController(
      screenManager: const ScreenManager(forceLandScapeInFullscreen: false),
      enabledButtons: const EnabledButtons(rewindAndfastForward: false),
      responsive: Responsive(buttonsSizeRelativeToScreen: 3));

  String fileName = '';
  final List<Quality> _qualities = [];
  Backend _dropdownValue = Backend.replicate;
  String _captions = '';
  final ValueNotifier<bool> _subtitlesEnabled = ValueNotifier(true);

  /// listener for the video quality
  final ValueNotifier<Quality?> _quality = ValueNotifier(null);

  final ValueNotifier<bool> _loading = ValueNotifier(false);

  Duration _currentPosition = Duration.zero; // to save the video position

  /// subscription to listen the video position changes
  StreamSubscription? _currentPositionSubs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // listen the video position
    _currentPositionSubs = _controller.onPositionChanged.listen(
      (Duration position) {
        _currentPosition = position; // save the video position
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _currentPositionSubs?.cancel();
    super.dispose();
  }

  Future<void> getYoutubeStreamUrl(String youtubeUrl) async {
    YoutubeExplode yt = YoutubeExplode();
    if (kIsWeb) {
      yt = YoutubeExplode(YoutubeHttpClient(CorsBypassClient()));
    }

    Video video = await yt.videos.get(youtubeUrl);

    StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(video.id);
    if (video.isLive) {
      // MuxedStreamInfo  streamInfo = manifest.muxed.withHighestBitrate();

      _qualities.add(Quality(
          url: await yt.videos.streamsClient.getHttpLiveStreamUrl(video.id),
          label: 'Live'));
    } else {
      for (var element in manifest.muxed) {
        _qualities.add(
            Quality(url: element.url.toString(), label: element.qualityLabel));
      }
    }
    if (_qualities.isEmpty) {
      throw Exception('No videos available');
    }
    _qualities.sort(
      (a, b) {
        return b.label.compareTo(a.label);
      },
    );
    // print('streamInfo ${streamInfo.url}');
    // Close the YoutubeExplode's http client.
    yt.close();
    // return streamInfo.url.toString();
  }

  Future<void> _setDataSource() async {
    // set the data source and play the video in the last video position
    await _controller.setDataSource(
      DataSource(
        type: DataSourceType.network,
        source: _quality.value!.url,
        closedCaptionFile: Future.value(SubRipCaptionFile(_captions)),
      ),
      autoplay: true,
      seekTo: _currentPosition,
    );
    _controller.onClosedCaptionEnabled(true);
  }

  void _onChangeVideoQuality() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: List.generate(
          _qualities.length,
          (index) {
            final quality = _qualities[index];
            return CupertinoActionSheetAction(
              child: Text(quality.label),
              onPressed: () {
                _quality.value = quality; // change the video quality
                _setDataSource(); // update the datasource
                Navigator.maybePop(_);
              },
            );
          },
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.maybePop(_),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  _playYoutubeVideo(CaptionedVideo video) async {
    await getYoutubeStreamUrl(video.link);

    _quality.value = _qualities[0];
    print(_quality.value!.url);
    _setDataSource();
  }

  TextEditingController url = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play YouTube video'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: url,
                    decoration: const InputDecoration(hintText: 'YouTube URL'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ValueListenableBuilder<bool>(
                      valueListenable: _loading,
                      builder: (context, bool loading, child) {
                        return loading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  _loading.value = true;
                                  _controller.pause();

                                  _qualities.clear();
                                  _quality.value = null;
                                  _currentPosition = Duration.zero;

                                  try {
                                    switch (_dropdownValue) {
                                      case Backend.replicate:
                                        {
                                          _captions = await WhisperApi
                                              .generateCaptionsReplicate(
                                              url.text);
                                        }
                                      case Backend.hugging:
                                        {
                                          _captions = await WhisperApi
                                              .generateCaptionsHuggingFace(
                                              url.text);
                                        }
                                      case Backend.local:
                                        {
                                          _captions = await WhisperApi
                                              .generateCaptionsBackend(
                                                  url.text);
                                        }
                                    }

                                    print(_captions);

                                    final CaptionedVideo video = CaptionedVideo(
                                        link: url.text, captions: _captions);

                                    try {
                                      await _playYoutubeVideo(video);
                                    } catch (e) {
                                      print(e);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Unable to play video: ${e.toString()}')));
                                      }
                                    }
                                  } catch (e, st) {
                                    print(e);
                                    print(st);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Unable to load captions: ${e.toString()}')));
                                    }
                                  }

                                  _loading.value = false;
                                },
                                child: const Text('Play'));
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: DropdownButton(
                    value: _dropdownValue,
                    items: const [
                      DropdownMenuItem(
                          value: Backend.replicate, child: Text('Replicate')),
                      DropdownMenuItem(
                          value: Backend.hugging, child: Text('Hugging Face')),
                      DropdownMenuItem(
                          value: Backend.local, child: Text('Local Backend')),
                    ],
                    onChanged: (Object? value) {
                      setState(() {
                        if (value is Backend) {
                          _dropdownValue = value;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: MeeduVideoPlayer(
                  controller: _controller,
                  bottomRight: (ctx, controller, responsive) {
                    // creates a responsive fontSize using the size of video container
                    final double fontSize = responsive.fontSize();

                    return Row(
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.all(5),
                          minSize: 25,
                          onPressed: _onChangeVideoQuality,
                          child: ValueListenableBuilder<Quality?>(
                            valueListenable: _quality,
                            builder: (context, Quality? quality, child) {
                              return Text(
                                quality != null
                                    ? quality.label
                                    : 'No qualities loaded',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.all(5),
                          minSize: 25,
                          child: ValueListenableBuilder(
                            valueListenable: _subtitlesEnabled,
                            builder: (BuildContext context, bool enabled, _) {
                              return Text(
                                "CC",
                                style: TextStyle(
                                  fontSize: fontSize > 18 ? 18 : fontSize,
                                  color: Colors.white.withOpacity(
                                    enabled ? 1 : 0.4,
                                  ),
                                ),
                              );
                            },
                          ),
                          onPressed: () {
                            _subtitlesEnabled.value = !_subtitlesEnabled.value;
                            _controller.onClosedCaptionEnabled(
                                _subtitlesEnabled.value);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
