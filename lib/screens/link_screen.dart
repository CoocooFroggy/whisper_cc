import 'package:flutter/material.dart';
import 'package:whisper_cc/logic/api.dart';
import 'package:whisper_cc/objects/backend_enum.dart';
import 'package:whisper_cc/objects/video.dart';
import 'package:whisper_cc/screens/youtube_screen.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

/// Regular expression for YouTube links
final youtubeRegex = RegExp(
    r'http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?');

class _LinkScreenState extends State<LinkScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  String? _id;
  Backend _dropdownValue = Backend.hugging;
  double _progress = -1;

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
              const Text('Choose the backend.'),
              DropdownButton(
                value: _dropdownValue,
                items: const [
                  DropdownMenuItem(
                      value: Backend.hugging, child: Text('Hugging Face')),
                  DropdownMenuItem(
                      value: Backend.replicate, child: Text('Replicate')),
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                          });
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            final url = 'https://youtube.com/watch?v=$_id';
                            final String captions;

                            switch (_dropdownValue) {
                              case Backend.replicate:
                                {
                                  captions = await WhisperApi
                                      .generateCaptionsReplicate(url);
                                }
                              case Backend.hugging:
                                {
                                  captions = await WhisperApi
                                      .generateCaptionsHuggingFace(url);
                                }
                              case Backend.local:
                                {
                                  captions =
                                      await WhisperApi.generateCaptionsBackend(
                                          url);
                                }
                            }

                            print(captions);

                            final video =
                                CaptionedVideo(link: url, captions: captions);

                            if (!mounted) return;

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        YoutubeExamplePage(video: video)));
                          }
                          setState(() {
                            _loading = false;
                          });
                        },
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
              ),
              // Only show progress if we need to
              (_progress != -1)
                  ? LinearProgressIndicator(value: _progress)
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
