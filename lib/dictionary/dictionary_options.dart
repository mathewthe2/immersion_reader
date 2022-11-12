enum PitchAccentDisplayStyle { none, graph, number }

enum PopupDictionaryTheme { dark, dracula, light, purple }

class DictionaryOptions {
  List<int> disabledDictionaryIds;
  bool isGetFrequencyTags;
  PitchAccentDisplayStyle pitchAccentDisplayStyle;
  PopupDictionaryTheme popupDictionaryTheme;

  bool sorted;

  DictionaryOptions(
      {this.disabledDictionaryIds = const [],
      this.isGetFrequencyTags = true,
      this.pitchAccentDisplayStyle = PitchAccentDisplayStyle.graph,
      this.popupDictionaryTheme = PopupDictionaryTheme.dark,
      this.sorted = true});
}
