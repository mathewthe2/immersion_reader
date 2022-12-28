import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:immersion_reader/widgets/my_books/book_goal/read_recent_button.dart';

class BookGoalProgressWidget extends StatelessWidget {
  final ProfileDailyProgress profileDailyProgress;
  final Function(String mediaIdentifier)? onTapBook;
  final Widget? child;
  final bool? isShowTitle;
  static const String todaysReadingLabel = "Today's Reading";

  const BookGoalProgressWidget(
      {super.key,
      required this.profileDailyProgress,
      this.onTapBook,
      this.child,
      this.isShowTitle});

  @override
  Widget build(BuildContext context) {
    bool isShowReadingLabel = (isShowTitle == null || isShowTitle!);
    return Column(children: [
      SleekCircularSlider(
          appearance: CircularSliderAppearance(
              size: 300,
              startAngle: 180,
              angleRange: 180,
              customWidths: CustomSliderWidths(progressBarWidth: 10),
              customColors: CustomSliderColors(
                  progressBarColor: const Color(0xFFDCD8FF),
                  dotColor: const Color(0xFFDCD8FF),
                  hideShadow: true,
                  trackColor: CupertinoColors.systemGroupedBackground)),
          initialValue: profileDailyProgress.getPercentageReadToday(),
          innerWidget: (double value) {
            return Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    if (isShowReadingLabel)
                      Text(todaysReadingLabel,
                          style: TextStyle(
                              color:
                                  CupertinoColors.label.resolveFrom(context))),
                    Text(
                      profileDailyProgress.getTimeReadToday(),
                      style: TextStyle(
                          fontSize: isShowReadingLabel ? 50 : 70,
                          color: CupertinoColors.label.resolveFrom(context)),
                    ),
                    Text(
                      'of my ${profileDailyProgress.getGoalMinutes()}-minute goal',
                      style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context)),
                    ),
                    if (onTapBook != null) const SizedBox(height: 25),
                    if (onTapBook != null)
                      ReadRecentButton(
                          profileDailyProgress: profileDailyProgress,
                          onTapBook: onTapBook!),
                    if (child != null) child!
                  ],
                ));
          }),
    ]);
  }
}
