extension DateTimeExtension on DateTime {
  static const List<String> daysInWeek = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<String> daysInWeekFull = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  bool isToday() {
    DateTime now = DateTime.now();
    return DateTime(year, month, day)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays ==
        0;
  }

  DateTime dateOnly() {
    return DateTime(year, month, day);
  }

  String dayOfWeek() {
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    if (weekday < 1 || weekday > 7) {
      return '';
    }
    return daysInWeek[now.weekday];
  }

  String dayInEnglish() {
    return daysInWeekFull[weekday];
  }

}
