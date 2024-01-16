import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';
import 'package:immersion_reader/managers/navigation/navigation_manager.dart';
import 'package:immersion_reader/utils/sleek_circular_slider/appearance.dart';
import 'package:immersion_reader/utils/sleek_circular_slider/circular_slider.dart';
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
    bool isShowBottomContent = isShowReadingLabel || child != null;
    return ClipRect(
        child: Align(
            alignment: Alignment.topCenter,
            heightFactor: isShowBottomContent ? 0.8 : 0.55,
            child: ValueListenableBuilder(
                valueListenable: NavigationManager().leaveReaderPageNotifier,
                builder: (context, val, child) => SleekCircularSlider(
                    appearance: CircularSliderAppearance(
                        size: 350,
                        startAngle: 180,
                        angleRange: 180,
                        animationEnabled: !(val as bool),
                        customWidths: CustomSliderWidths(progressBarWidth: 10),
                        customColors: CustomSliderColors(
                            progressBarColor: const Color(0xFFDCD8FF),
                            dotColor: const Color(0xFFDCD8FF),
                            hideShadow: true,
                            trackColor:
                                CupertinoColors.systemGroupedBackground)),
                    initialValue:
                        val ? 0 : profileDailyProgress.getPercentageReadToday(),
                    innerWidget: (double value) {
                      return Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Text(todaysReadingLabel,
                                  style: TextStyle(
                                      color: CupertinoColors.label
                                          .resolveFrom(context))),
                              Text(
                                profileDailyProgress.getTimeReadToday(),
                                style: TextStyle(
                                    fontSize: isShowReadingLabel ? 65 : 85,
                                    color: CupertinoColors.label
                                        .resolveFrom(context)),
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'of my ${profileDailyProgress.getGoalMinutes()}-minute goal',
                                      style: TextStyle(
                                          color: CupertinoColors.label
                                              .resolveFrom(context)),
                                    ),
                                    if (onTapBook != null)
                                      const Icon(
                                          size: 18,
                                          CupertinoIcons.forward,
                                          color: CupertinoColors.inactiveGray),
                                  ]),
                              if (onTapBook != null) const SizedBox(height: 25),
                              if (onTapBook != null)
                                ReadRecentButton(
                                    profileDailyProgress: profileDailyProgress,
                                    onTapBook: onTapBook!),
                              if (child != null) child
                            ],
                          ));
                    }))));
  }
}
