import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/profile/profile_content_stats.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:immersion_reader/widgets/my_books/book_widget.dart';

class BookStatsRow extends StatelessWidget {
  final ProfileContentStats contentStats;
  const BookStatsRow({super.key, required this.contentStats});

  @override
  Widget build(BuildContext context) {
    Widget statsRow(String label, String value) {
      return RichText(
          text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.label.resolveFrom(context),
        ),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
              text: value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ));
    }

    return Column(children: [
      SizedBox(
          height: 200,
          child: Row(children: [
            BookWidget(
                book: contentStats.profileContent.book,
                width: 130,
                onTap: (mediaIdentifier) {}),
            Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    statsRow('Characters read',
                        contentStats.charactersReadOverTotal()),
                    statsRow('Reading speed',
                        '${contentStats.charactersReadPerSecond()} char/s'),
                           statsRow('Last read',
                        timeago.format(contentStats.profileContent.lastOpened)),
                  ],
                ))
          ])),
    ]);
  }
}
