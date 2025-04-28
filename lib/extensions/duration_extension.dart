extension DurationExtension on Duration {
  String toHumanString() {
    // Convert the Duration to a standard string format (hh:mm:ss)
    String durationString = toString().split('.').first.padLeft(8, "0");

    // If the duration is less than 1 hour, remove the leading "00:"
    if (inHours == 0) {
      durationString = durationString.substring(3);
    }

    return durationString;
  }
}
