import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/common/divider.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';
import 'package:immersion_reader/providers/profile_provider.dart';
import 'package:immersion_reader/widgets/my_books/book_goal/book_goal_progress_widget.dart';

class BookGoalDetailSheet extends StatefulWidget {
  final ProfileDailyProgress profileDailyProgress;
  final ProfileProvider profileProvider;
  const BookGoalDetailSheet(
      {super.key,
      required this.profileDailyProgress,
      required this.profileProvider});

  @override
  State<BookGoalDetailSheet> createState() => _BookGoalDetailSheetState();
}

const double _kItemExtent = 32.0;
const int maxMinutes = 1440;
List<int> _minutes = [for (int i = 1; i <= maxMinutes; i += 1) i];

class _BookGoalDetailSheetState extends State<BookGoalDetailSheet> {
  // static const String shareGoalProgressLabel = 'SHARE';
  static const String adjustGoalLabel = 'ADJUST GOAL';
  static const String doneLabel = 'Done';
  late int selectedReadingMinutes;
  bool updatedReadingMinutes = false;

  @override
  void initState() {
    selectedReadingMinutes = widget.profileDailyProgress.getGoalMinutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedReadingMinutes < 1 || selectedReadingMinutes > maxMinutes) {
      return const Center(child: Text('Invalid goal minutes'));
    }
    return Column(children: [
      Align(
          alignment: Alignment.centerRight,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                      size: 22,
                      CupertinoIcons.xmark_circle_fill,
                      color: CupertinoColors.inactiveGray)))),
      BookGoalProgressWidget(
        profileDailyProgress: widget.profileDailyProgress,
        isShowTitle: false,
      ),
      const SizedBox(height: 30),
      Divider(
          indent: 40,
          endIndent: 40,
          color: CupertinoColors.systemGrey3.resolveFrom(context)),
      const SizedBox(height: 30),
      // Text(widget.profileDailyProgress.getDayOfWeek()),
      Text(BookGoalProgressWidget.todaysReadingLabel,
          style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 25,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(widget.profileDailyProgress.getReadingTimeToGo(),
          style: const TextStyle(color: Color(0xFF9B99E9), fontSize: 20)),
      // Container(child: const Text(shareGoalProgressLabel)),
      const SizedBox(height: 90),
      CupertinoButton(
          child: Text(
            adjustGoalLabel,
            style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
          ),
          onPressed: () {
            _showDialog(
              context: context,
              whenComplete: () {
                if (updatedReadingMinutes) {
                  widget.profileProvider.updateGoalMinutes(
                      widget.profileDailyProgress.goalId,
                      selectedReadingMinutes);
                  widget.profileDailyProgress.goalSeconds =
                      selectedReadingMinutes * 60;
                  updatedReadingMinutes = false;
                }
              },
              child: CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                scrollController: FixedExtentScrollController(
                    initialItem: selectedReadingMinutes - 1), // first item = 1
                useMagnifier: true,
                itemExtent: _kItemExtent,
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    selectedReadingMinutes = selectedItem + 1;
                    updatedReadingMinutes = true;
                  });
                },
                children: List<Widget>.generate(_minutes.length, (int index) {
                  return Center(
                    child: Text(
                      _minutes[index].toString(),
                    ),
                  );
                }),
              ),
            );
          })
    ]);
  }

  void _showDialog(
      {required Widget child,
      required VoidCallback whenComplete,
      required BuildContext context}) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => Container(
            height: MediaQuery.of(context).size.height * .40,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(children: [
              Container(
                alignment: Alignment.topCenter,
                height: 50,
                decoration: BoxDecoration(
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    border: Border(
                        bottom: BorderSide(
                            color: CupertinoColors.tertiarySystemFill
                                .resolveFrom(context)))),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Daily Reading Goal',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label.resolveFrom(context)),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(doneLabel,
                              style: TextStyle(
                                  color: CupertinoColors.label
                                      .resolveFrom(context))),
                        ))
                  ],
                ),
              ),
              Expanded(child: child)
            ]))).whenComplete(whenComplete);
  }
}
