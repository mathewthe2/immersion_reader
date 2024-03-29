import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/managers/profile/profile_manager.dart';
import 'package:immersion_reader/widgets/my_books/book_goal/book_goal_detail_sheet.dart';
import 'package:immersion_reader/widgets/my_books/book_goal/book_goal_progress_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:immersion_reader/dto/profile/profile_daily_progress.dart';

class BookGoalWidget extends StatefulWidget {
  final Function(String mediaIdentifier) onTapBook;
  final Widget? child;
  const BookGoalWidget(
      {super.key, required this.onTapBook, this.child});

  @override
  State<BookGoalWidget> createState() => _BookGoalWidgetState();
}

class _BookGoalWidgetState extends State<BookGoalWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileDailyProgress?>(
      future: ProfileManager().getDailyReadingProgress(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return GestureDetector(
              onTap: () {
                showCupertinoModalBottomSheet(
                    context: context,
                    expand: true,
                    builder: (context) => SafeArea(
                        child: BookGoalDetailSheet(
                            profileDailyProgress: snapshot.data!)));
              },
              child: BookGoalProgressWidget(
                profileDailyProgress: snapshot.data!,
                onTapBook: widget.onTapBook,
                child: widget.child
              ));
        }
        return const Text('loading');
      },
    );
  }
}
