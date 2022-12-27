import 'package:flutter/cupertino.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';
import 'package:immersion_reader/providers/profile_provider.dart';

class BookGoalWidget extends StatefulWidget {
  final ProfileProvider profileProvider;
  final Function(String mediaIdentifier) onTapBook;
  const BookGoalWidget(
      {super.key, required this.profileProvider, required this.onTapBook});

  @override
  State<BookGoalWidget> createState() => _BookGoalWidgetState();
}

class _BookGoalWidgetState extends State<BookGoalWidget> {
  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemBackground),
        context);
    Color invertedTextColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemBackground,
            darkColor: CupertinoColors.white),
        context);
    return FutureBuilder<ProfileDailyProgress?>(
      future: widget.profileProvider.getDailyReadingProgress(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
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
                initialValue: snapshot.data!.getPercentageReadToday(),
                innerWidget: (double value) {
                  return Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          Text("Today's Reading",
                              style: TextStyle(color: textColor)),
                          Text(
                            snapshot.data!.getTimeReadToday(),
                            style: TextStyle(fontSize: 50, color: textColor),
                          ),
                          Text(
                            'of my ${snapshot.data!.getGoalMinutes()}-minute goal',
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 25),
                          GestureDetector(
                              onTap: () => widget.onTapBook(
                                  snapshot.data!.getMediaIdentifier()),
                              child: Container(
                                  width: 500,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.darkBackgroundGray,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Keep Reading',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: invertedTextColor)),
                                        Container(
                                          width: 250,
                                          alignment: Alignment.center,
                                          child: Text(
                                              snapshot.data!
                                                  .getRecentBookTitle(),
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: invertedTextColor)),
                                        ),
                                      ])))
                        ],
                      ));
                }),
          ]);
        }
        return const Text('loading');
      },
    );
  }
}
