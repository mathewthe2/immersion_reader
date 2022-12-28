import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';

class ReadRecentButton extends StatelessWidget {
  final ProfileDailyProgress profileDailyProgress;
  final Function(String mediaIdentifier) onTapBook;
  static const String keepReadingLabel = 'Keep Reading';

  const ReadRecentButton(
      {super.key, required this.profileDailyProgress, required this.onTapBook});

  @override
  Widget build(BuildContext context) {
    String bookTitle = profileDailyProgress.getRecentBookTitle();
    if (bookTitle.isEmpty) {
      return Container();
    }
    Color buttonTextColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemBackground,
            darkColor: CupertinoColors.white),
        context);
    return GestureDetector(
        onTap: () => onTapBook(profileDailyProgress.getMediaIdentifier()),
        child: Container(
            width: 500,
            height: 60,
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(keepReadingLabel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: buttonTextColor)),
              Container(
                width: 250,
                alignment: Alignment.center,
                child: Text(profileDailyProgress.getRecentBookTitle(),
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: buttonTextColor)),
              ),
            ])));
  }
}
