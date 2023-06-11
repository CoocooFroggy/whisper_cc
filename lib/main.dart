import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:whisper_cc/screens/link_screen.dart';

void main() {
  initMeeduPlayer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whisper CC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,

      // DEBUG
      // home: const LinkScreen(),
      // home: VideoScreen(video: Video(link: 'https://www.youtube.com/watch?v=7I9fbbhYnuc', captions: 'Nice')),
      home: const LinkScreen(),
    );
  }
}
