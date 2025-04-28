extension ListExtension<T> on List<T> {
  List<T> truncateTo(int maxLength) =>
      (length <= maxLength) ? this : sublist(0, maxLength);
}
