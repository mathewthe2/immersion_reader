class BookBookmark {
  int? id;
  int bookId;
  int? exploredCharCount;
  double? progress;

  BookBookmark(
      {this.id, required this.bookId, this.exploredCharCount, this.progress});

  factory BookBookmark.fromMap(Map<String, Object?> map) => BookBookmark(
      id: map['id'] as int?,
      bookId: map['bookId'] != null
          ? map['bookId'] as int
          : map['dataId'] as int, // ttu uses dataId as bookId
      exploredCharCount: map['exploredCharCount'] as int?,
      progress: map['progress'] is int
          ? (map['progress'] as int).toDouble()
          : map['progress'] as double?);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dataId': bookId,
      'exploredCharCount': exploredCharCount,
      'progress': progress,
    };
  }
}
