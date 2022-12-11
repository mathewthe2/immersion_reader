import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserTopBar extends StatefulWidget {
  final InAppWebViewController webViewController;
  const BrowserTopBar({super.key, required this.webViewController});

  @override
  State<BrowserTopBar> createState() => _BrowserBarState();
}

class _BrowserBarState extends State<BrowserTopBar> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: 'https://syosetu.com/');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void handleSubmitUrl(String input) {
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'http://$input';
    }
    var url = Uri.parse(input);
    if (url.scheme.isEmpty) {
      url = Uri.parse(input);
    }
    widget.webViewController.loadUrl(urlRequest: URLRequest(url: url));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
        controller: _textController, onSubmitted: handleSubmitUrl);
  }
}
