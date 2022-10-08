class PitchData {
  /// Initialise a dictionary entry with given details of a certain word.
  PitchData({
    required this.reading,
    required this.downstep,
  });

  /// The pronunciation of the word represented by this dictionary entry.
  final String reading;

  /// The downstep for this term's reading.
  final int downstep;
}
