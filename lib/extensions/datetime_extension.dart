extension DateTimeExtension on DateTime {
  bool isToday() {
    DateTime now = DateTime.now();
    return DateTime(year, month, day)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays ==
        0;
  }
}
