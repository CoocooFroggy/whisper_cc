import 'package:whisper_cc/objects/segment.dart';

class Subtitles {
  /// Generates a SRT subtitle file from [segments]
  static String generateSubtitles(List<Segment> segments) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      buffer
        ..writeln(i)
        ..writeln('${formatTime(segment.start)} --> ${formatTime(segment.end)}')
        ..writeln(segment.text)
        ..writeln();
    }
    return buffer.toString();
  }

  /// Formats the given [seconds] into an SRT subtitle timestamp.
  ///
  /// The [seconds] parameter represents the time duration in seconds.
  /// The formatted timestamp follows the format HH:MM:SS,MMM.
  /// HH represents hours, MM represents minutes, SS represents seconds,
  /// and MMM represents milliseconds.
  ///
  /// Returns the formatted SRT subtitle timestamp as a [String].
  static String formatTime(double seconds) {
    int hours = (seconds / 3600).floor();
    int minutes = ((seconds % 3600) / 60).floor();
    int secs = (seconds % 60).floor();
    int milliseconds = ((seconds % 1) * 1000).round();

    String formattedTime =
        '${_formatTwoDigits(hours)}:${_formatTwoDigits(minutes)}:${_formatTwoDigits(secs)},${_formatMilliseconds(milliseconds)}';
    return formattedTime;
  }

  static String _formatTwoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  static String _formatMilliseconds(int number) {
    return number.toString().padLeft(3, '0');
  }
}