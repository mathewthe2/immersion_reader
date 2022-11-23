import 'package:flutter/cupertino.dart';
import 'package:transparent_image/transparent_image.dart';

class DiscoverBox extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const DiscoverBox({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Stack(alignment: Alignment.bottomLeft, children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                      aspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 1.8),
                      child: FadeInImage.memoryNetwork(
                        imageErrorBuilder: (_, __, ___) =>
                            const SizedBox.shrink(),
                        placeholder: kTransparentImage,
                        image: "https://www.immersionkit.com/reader/ducks.jpg",
                        alignment: Alignment.topCenter,
                        fit: BoxFit.cover,
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
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(18))),
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
                  height: constraints.maxHeight * 0.40,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                            color: CupertinoColors.white, fontSize: 16),
                      )),
                );
              }),
              const SizedBox(
                height: 5,
              ),
              subtitle != null
                  ? Text(
                      subtitle!,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: CupertinoColors.black),
                    )
                  : Container(),
            ])));
  }
}
