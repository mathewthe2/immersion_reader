import 'package:flutter/cupertino.dart';
// import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:immersion_reader/data/profile/profile_daily_stats.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';
import 'package:immersion_reader/providers/profile_provider.dart';
import 'package:immersion_reader/widgets/common/heatmap/heatmap_calendar.dart';

class BookGoalHeatMap extends StatefulWidget {
  final ProfileProvider profileProvider;
  final ProfileDailyProgress profileDailyProgress;

  const BookGoalHeatMap(
      {super.key,
      required this.profileProvider,
      required this.profileDailyProgress});

  @override
  State<BookGoalHeatMap> createState() => _BookGoalHeatMapState();
}

class _BookGoalHeatMapState extends State<BookGoalHeatMap> {
  Map<DateTime, int> datasets = {};

  @override
  void initState() {
    super.initState();
    setDailyStats(DateTime.now());
  }

  Future<void> setDailyStats(DateTime datetime) async {
    List<ProfileDailyStats> dailyStats = await widget.profileProvider
        .getDailyStats(month: datetime.month, year: datetime.year);
    setState(() {
      datasets = {
        for (ProfileDailyStats stat in dailyStats) stat.date: stat.totalSeconds
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: HeatMapCalendar(
              defaultColor: CupertinoColors.systemBackground.resolveFrom(context),
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
                // print(value);
              },
            ));
  }
}
