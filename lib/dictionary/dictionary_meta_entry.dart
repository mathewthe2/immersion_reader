import './pitch_data.dart';

class DictionaryMetaEntry {
  /// Initialise a dictionary entry with given details of a certain word.
  DictionaryMetaEntry({
    required this.dictionaryName,
    required this.term,
    this.pitches,
    this.frequency,
    this.id,
  });

  /// A unique identifier for the purposes of database storage.
  int? id;

  /// The word or phrase represented by this dictionary entry.
  final String term;

  /// Length of the term.
  int get termLength => term.length;

  /// The dictionary from which this entry was imported from. This is used for
  /// database query purposes.
  final String dictionaryName;

  /// The frequency of this term.
  final String? frequency;

  /// List of pitch accent downsteps for this term's reading.
  final List<PitchData>? pitches;

  @override
  operator ==(Object other) => other is DictionaryMetaEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
