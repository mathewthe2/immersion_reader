extension ObjectExtension on Object? {
  double get toDouble =>
      this is int ? (this as int).toDouble() : this as double;
}
