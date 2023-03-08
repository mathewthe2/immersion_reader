import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/profile/profile_daily_stats.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';
import 'package:immersion_reader/managers/profile/profile_manager.dart';
import 'package:immersion_reader/widgets/common/heatmap/heatmap_calendar.dart';
import 'package:immersion_reader/extensions/datetime_extension.dart';

class BookGoalHeatMap extends StatefulWidget {
  final ProfileDailyProgress profileDailyProgress;

  const BookGoalHeatMap(
      {super.key,
      required this.profileDailyProgress});

  @override
  State<BookGoalHeatMap> createState() => _BookGoalHeatMapState();
}

class _BookGoalHeatMapState extends State<BookGoalHeatMap> {
  Map<DateTime, int> datasets = {};
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    setDailyStats(DateTime.now());
  }

  Future<void> setDailyStats(DateTime datetime) async {
    List<ProfileDailyStats> dailyStats = await ProfileManager()
        .getDailyStats(month: datetime.month, year: datetime.year);
    setState(() {
      datasets = {
        for (ProfileDailyStats stat in dailyStats) stat.date: stat.totalSeconds
      };
    });
  }

  String getTimeReadString(DateTime? date) {
    if (selectedDate == null) {
      return '';
    } else {
      int totalSeconds = datasets[date] ?? 0;
      int minutes = totalSeconds ~/ 60;
      if (minutes <= 1) {
        return '${selectedDate!.dayInEnglish()} : 1 minute';
      } else {
        return '${selectedDate!.dayInEnglish()} : $minutes minutes';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
          child: Container(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: HeatMapCalendar(
                defaultColor:
                    CupertinoColors.systemBackground.resolveFrom(context),
                monthTextColor: CupertinoColors.label.resolveFrom(context),
                flexible: true,
                showColorTip: false,
                datasets: datasets,
                colorsets: const {
                  1: CupertinoColors.systemRed,
                  3: CupertinoColors.systemOrange,
                  5: CupertinoColors.systemYellow,
                  7: CupertinoColors.systemGreen,
                  9: CupertinoColors.systemBlue,
                  11: CupertinoColors.systemIndigo,
                  13: CupertinoColors.systemPurple,
                },
                onMonthChange: (value) async {
                  setDailyStats(value);
                },
                onClick: (value) {
                  setState(() {
                    selectedDate = datasets.containsKey(value) ? value : null;
                  });
                },
              )),
          onTap: () {
            setState(() {
              selectedDate = null;
            });
          }),
      Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(getTimeReadString(selectedDate),
                  style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context)))))
    ]);
  }
}
