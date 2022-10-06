import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import './japanese/vocabulary.dart';
import './japanese/translator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/reader/vocabulary_tile.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  Translator? translator;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future(() async {
      translator = await Translator.create();
    });
  }

// 8A2BE2
  String colorCorrectedPitch(String pitchSvg) {
    const String pitchGraphStrokeColor = '#FFF0F5';
    const String pitchGraphContrastColor = '#4B0082';
    pitchSvg = pitchSvg
        .replaceAll(RegExp(r'#000'), pitchGraphStrokeColor)
        .replaceAll(RegExp(r'#fff'), pitchGraphContrastColor);
    return pitchSvg;
  }

  Widget vocabularyPitch(Vocabulary vocabulary) {
    return (vocabulary.pitchSvg ?? []).isEmpty
        ? const Text('')
        : SvgPicture.string(colorCorrectedPitch(vocabulary.pitchSvg![0]),
            height: 25);
  }

  // Widget vocabularyTile(Vocabulary vocabulary) {
  //   return Text(vocabulary.expression ?? '',
  //       style: const TextStyle(
  //           fontWeight: FontWeight.w400, fontSize: 20, color: Colors.white70));
  // }

  List<TextSpan>? splitList(BuildContext context, String data) {
    List<TextSpan> result = [];
    for (int i = 0; i < data.length; i++) {
      String char = data.substring(i, i + 1);
      result.add(TextSpan(
          text: char,
          style: const TextStyle(fontSize: 20, color: Colors.black),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (translator == null) {
                return;
              }
              String sentence = data.substring(i, data.length);
              List<Vocabulary> vocabs = await translator!.findTerm(sentence);

              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                        height: 200,
                        color: Colors.black87,
                        child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: ListTile.divideTiles(
                                  context: context,
                                  color: Colors.white70,
                                  tiles: vocabs.map(
                                      (Vocabulary vocabulary) => VocabularyTile(
                                            vocabulary: vocabulary,
                                            added: false,
                                            addOrRemoveVocabulary: () {},
                                          ))).toList()),
                        ));
                  });
            }));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('ブックリーダー'),
        // ),
        body: FutureBuilder<String>(
            future: getStuff(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: RichText(
                            text: TextSpan(
                                text: '',
                                children:
                                    splitList(context, snapshot.data!)))));
              } else {
                return const Text('no data');
              }
            }));
  }

  @override
  Future<String> getStuff() async {
    // Translator t = await Translator.create();
    // List<Vocabulary> vocabs = await t.findTerm('魔界');
    // print(vocabs.map((Vocabulary a) => a.expression).toList());
    // print(vocabs.map((Vocabulary a) => a.glossary![0]).toList());
    // t.findTerm('殺して');

    // Pitch p = await Pitch.create();
    // List<String> s = await p.getSvg('４月', reading: 'しがつ');
    // print(s[0]);

    return "岸田文雄首相は4日に自身の長男で公設秘書の翔太郎氏を首相秘書官とする人事を発令する方針を固めた。政府関係者が明らかにした。理由については「首相官邸内の人事の活性化と岸田事務所との連携強化のためだ」と説明している。";
  }
}
