import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:transparent_image/transparent_image.dart';
// import 'package:flutter/material.dart';

class BookWidget extends StatelessWidget {
  final Book book;
  final Function(String mediaIdentifier) onTap;
  const BookWidget({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onTap(book.mediaIdentifier ?? ''),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                      // width: constraints.maxWidth,
                      // height: 200,
                      child: ColoredBox(
                    color: CupertinoColors.darkBackgroundGray.withOpacity(0.3),
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
                        )),
                  ))),
              LayoutBuilder(builder: (context, constraints) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.darkBackgroundGray.withOpacity(0.2),
                        CupertinoColors.darkBackgroundGray.withOpacity(0.4)
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
                  height: constraints.maxHeight * 0.38,
                  width: double.maxFinite,
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
