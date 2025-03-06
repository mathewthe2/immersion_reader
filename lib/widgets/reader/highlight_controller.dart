class HighlightController {
  Function(String javascript)? evaluateJavascript;

  HighlightController._internal({this.evaluateJavascript});

  factory HighlightController(
          {Function(String javascript)? evaluateJavascript}) =>
      HighlightController._internal(evaluateJavascript: evaluateJavascript);

  void highlightLastSelected(int initialOffset, int textLength) {
    if (evaluateJavascript != null) {
      evaluateJavascript!("highlightLast($initialOffset, $textLength)");
    }
  }

  void removeHighlight() {
    if (evaluateJavascript != null) {
      evaluateJavascript!("removeHighlight()");
    }
  }
}
