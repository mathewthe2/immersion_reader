import 'package:flutter/widgets.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:http/http.dart' as http;

class PopupDictionaryExamples extends StatefulWidget {
  final String text;
  final int characterIndex;
  const PopupDictionaryExamples({
    super.key,
    required this.text,
    required this.characterIndex,
  });

  @override
  State<PopupDictionaryExamples> createState() =>
      _PopupDictionaryExamplesState();
}

class _PopupDictionaryExamplesState extends State<PopupDictionaryExamples> {
  late final String word;

  @override
  void initState() {
    super.initState();
    word = widget.text[widget.characterIndex];
  }

  Future<http.Response> fetchAlbum() {
    return http.get(Uri.parse('https://apiv2.immersionkit.com/search?q=$word'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText("Immersion Kit"),
        // FutureBuilder(future: fetchAlbum(), builder: builder)
      ],
    );
  }
}
