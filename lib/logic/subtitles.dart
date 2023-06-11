class Subtitles {
  /// Generates a SRT subtitle file from Hugging Face output
  static String generateSubtitles(String hfOutput) {
    final timestampRegex = RegExp(
        r'^\[((?:\d{2}:)?\d{2}:\d{2}\.\d{3}) -> ((?:\d{2}:)?\d{2}:\d{2}\.\d{3})\] {2}(.*)$',
        multiLine: true);

    StringBuffer buffer = StringBuffer();

    int counter = 1;
    for (var match in timestampRegex.allMatches(hfOutput)) {
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