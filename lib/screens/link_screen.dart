import 'package:flutter/material.dart';
import 'package:whisper_cc/logic/api.dart';
import 'package:whisper_cc/logic/subtitles.dart';
import 'package:whisper_cc/objects/backend.dart';
import 'package:whisper_cc/objects/video.dart';
import 'package:whisper_cc/screens/youtube_screen.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

/// Regular expression for YouTube links
final youtubeRegex = RegExp(
    r'http(?:s?):\/\/(?:(?:www\.)|(?:m\.))?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?');

class _LinkScreenState extends State<LinkScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _id;
  double _progress = -1;
  double _newProgress = -1;
  late Duration _duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper CC'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter a YouTube link.'),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a link';
                  }
                  if (!youtubeRegex.hasMatch(value)) {
                    return 'Please enter a valid YouTube link';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  // validator ensures there's a match
                  final match = youtubeRegex.firstMatch(newValue!);
                  _id = match!.group(1);
                },
              ),
              const SizedBox(height: 20),
              // Only show progress if we need to
              if (_progress != -1)
                TweenAnimationBuilder(
                  tween: Tween<double>(
                    begin: _progress,
                    end: _newProgress,
                  ),
                  duration: _duration,
                  builder:
                      (BuildContext context, double? value, Widget? child) {
                    return LinearProgressIndicator(value: value);
                  },
                )
              else
                Center(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _runSubmit,
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Submit'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _runSubmit() {
    setState(() {
      _loading = true;
    });
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = 'https://youtube.com/watch?v=$_id';

      WhisperApi.generateCaptionsHuggingFace(url).listen((status) {
        switch (status) {
          case (QueuedBackendStatus s):
            _animateProgressBar(
                0.5, Duration(milliseconds: (s.rankEta * 1000).toInt()));
          case (StartingBackendStatus _):
            {
              _animateProgressBar(0.55, const Duration(milliseconds: 250));
            }
          case (RunningBackendStatus s):
            {
              switch (s.desc) {
                case RunningDesc.loadingAudio:
                  _animateProgressBar(0.6, const Duration(milliseconds: 250));
                case RunningDesc.preProcessing:
                  _animateProgressBar(0.65, const Duration(milliseconds: 250));
                case RunningDesc.transcribing:
                  _animateProgressBar(0.9, const Duration(seconds: 5));
              }
            }
          case (CompletedBackendStatus s):
            {
              _animateProgressBar(-1, Duration.zero);
              final captions = Subtitles.generateSubtitles(s.output);
              print(captions);

              final video = CaptionedVideo(link: url, captions: captions);

              if (!mounted) return;

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => YoutubeExamplePage(video: video)));

              setState(() {
                _loading = false;
              });
            }
        }
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _animateProgressBar(double newProgress, Duration duration) {
    setState(() {
      _newProgress = newProgress;
      _duration = duration;
    });
    _progress = newProgress;
  }
}
