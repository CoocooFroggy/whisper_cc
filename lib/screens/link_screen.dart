import 'package:flutter/material.dart';
import 'package:whisper_cc/logic/api.dart';
import 'package:whisper_cc/objects/video.dart';

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

  String? id;

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
                  id = match!.group(1);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        _loading = true;
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final String captions =
                              await WhisperApi.generateCaptionsBackend(id!);
                          // TODO
                          print(captions);

                          CaptionedVideo(link: 'https://youtube.com/watch?v=$id', captions: captions);
                        }
                        _loading = false;
                      },
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
