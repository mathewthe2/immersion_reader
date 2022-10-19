import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class FrequencyWidget extends StatelessWidget {
  final BuildContext parentContext;
  final Vocabulary vocabulary;
  const FrequencyWidget(
      {super.key, required this.parentContext, required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ...vocabulary.frequencyTags.map((frequencyTag) {
        return Container(
            decoration: BoxDecoration(
                color: const Color(0xffd46a6a),
                border: Border.all(
                  color: const Color(0xffd46a6a),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(7))),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(4),
            // color: CupertinoDynamicColor.resolve(
            //     const CupertinoDynamicColor.withBrightness(
            //         color: Color(0xffd46a6a), darkColor: CupertinoColors.black),
            //     parentContext),
            child: Row(children: [
              Text(frequencyTag.dictionaryName ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: CupertinoColors.white)),
              const SizedBox(width: 5),
              Text(frequencyTag.frequency,
                  style: const TextStyle(
                      fontSize: 12, color: CupertinoColors.white))
            ]));
      })
      // Text(vocabulary.frequencyTags.first.dictionaryName ?? ''),
      // Text(vocabulary.frequencyTags.first.frequency)
    ]);
  }
}
