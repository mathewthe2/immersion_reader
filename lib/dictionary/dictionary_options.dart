enum PitchAccentDisplayStyle { none, graph, number }

class DictionaryOptions {
  List<int> disabledDictionaryIds;
  bool isGetFrequencyTags;
  PitchAccentDisplayStyle pitchAccentDisplayStyle;

  bool sorted;

  DictionaryOptions(
      {this.disabledDictionaryIds = const [],
      this.isGetFrequencyTags = true,
      this.pitchAccentDisplayStyle = PitchAccentDisplayStyle.graph,
      this.sorted = true});
}
