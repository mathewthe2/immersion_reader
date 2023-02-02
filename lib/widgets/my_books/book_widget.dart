import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/utils/system_theme.dart';
import 'package:transparent_image/transparent_image.dart';

class BookWidget extends StatelessWidget {
  final Book book;
  final Function(String mediaIdentifier) onTap;
  final double? width;
  const BookWidget(
      {super.key, required this.book, required this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onTap(book.mediaIdentifier ?? ''),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                      // width: double.maxFinite,
                      // height: 200,
                      // width: 200,
                      width: width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColoredBox(
                            color: CupertinoColors.darkBackgroundGray
                                .withOpacity(0.3),
                            child: AspectRatio(
                                aspectRatio: MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 1.8),
                                child: FadeInImage(
                                  imageErrorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: book.getDisplayThumbnail(),
                                  alignment: Alignment.topCenter,
                                  fit: BoxFit.cover,
                                ))),
                      ))),
              LayoutBuilder(builder: (context, constraints) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.darkBackgroundGray.withOpacity(0.4),
                          CupertinoColors.darkBackgroundGray.withOpacity(0.5)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xff4A80F0)
                                .withOpacity(isDarkMode() ? 0.2 : 0.4),
                            offset: isDarkMode()
                                ? const Offset(0, 3)
                                : const Offset(5, 5),
                            blurRadius: 12),
                      ]),
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
                  height: constraints.maxHeight * 0.38,
                  width: width ?? double.maxFinite,
                  // width: constraints.maxWidth,
                  // width: 200,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        book.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                );
              }),
              // LinearProgressIndicator(
              //   value: (book.position! / book.duration!) == double.nan ||
              //           (book.position! / book.duration!) == double.infinity ||
              //           (book.position == 0 && book.duration == 0)
              //       ? 0
              //       : (book.position! / book.duration!),
              //   backgroundColor: Colors.white.withOpacity(0.6),
              //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              //   minHeight: 2,
              // ),
            ],
          ),
        ));
  }
}
