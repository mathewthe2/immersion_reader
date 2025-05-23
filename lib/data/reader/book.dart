import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitles_data.dart';
import 'package:immersion_reader/data/reader/book_blob.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/data/reader/book_section.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:immersion_reader/utils/cached_memory_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class Book {
  String title;
  int? id;
  int? version;
  DateTime? lastReadTime;
  String? coverImage;
  String? authorIdentifier;
  String? elementHtml;
  String? elementHtmlBackup;
  String? styleSheet;
  List<BookSection>? sections;
  List<BookBlob>? blobs;
  bool? hasThumb;
  BookBookmark? bookmark;

  // audio books
  int? playBackPositionInMs;
  int? matchedSubtitles;
  AudioBookFiles? audioBookFiles;
  Metadata? audioFileMetadata;
  SubtitlesData? subtitlesData;

  // for online books
  String? imageUrl;
  String? contentUrl;

  Book(
      {required this.title,
      this.hasThumb,
      this.id,
      this.lastReadTime,
      this.coverImage,
      this.authorIdentifier,
      this.elementHtml,
      this.elementHtmlBackup,
      this.playBackPositionInMs,
      this.audioBookFiles,
      this.audioFileMetadata,
      this.matchedSubtitles,
      this.styleSheet,
      this.sections,
      this.blobs,
      this.bookmark,
      this.imageUrl,
      this.contentUrl,
      this.version});

  factory Book.fromMap(Map<String, Object?> map) => Book(
      title: map['title'] as String,
      id: map['id'] as int?,
      version: map['version'] as int?,
      lastReadTime: map['lastReadTime'] != null
          ? DateTime.parse(map['lastReadTime'] as String)
          : null,
      authorIdentifier: map['authorIdentifier'] != null
          ? map['authorIdentifier'] as String
          : '',
      elementHtml: map['elementHtml'] as String?,
      elementHtmlBackup: map['elementHtmlBackup'] as String?,
      playBackPositionInMs: map['playBackPositionInMs'] as int?,
      matchedSubtitles: map['matchedSubtitles'] as int?,
      styleSheet: map['styleSheet'] as String?,
      coverImage: getCoverImageFromMap(map),
      sections: map['sections'] != null
          ? (map['sections'] as List<dynamic>)
              .map((section) => BookSection.fromMap(section))
              .toList()
          : [],
      blobs: map['blobs'] != null
          ? (map['blobs'] as List<dynamic>)
              .map((blob) => BookBlob.fromMap(blob))
              .toList()
          : [],
      hasThumb: getHasThumbFromMap(map));

  static const int latestVersion = 2;

  static String getCoverImageFromMap(Map<String, Object?> map) {
    if (map.containsKey("coverImage") && map["coverImage"] is String) {
      return map["coverImage"] as String;
    } else if (map.containsKey("coverImagePrefix") &&
        (map["coverImagePrefix"] is String) &&
        map.containsKey("coverImageData")) {
      return '${map['coverImagePrefix'] as String}, ${map['coverImageData']})}';
    }
    return "";
  }

  // deprecated - only for migration purposes
  static String getCoverImageFromDatabaseResult(Map<String, Object?> map) {
    if (map.containsKey("coverImage") && map["coverImage"] is String) {
      return map["coverImage"] as String;
    } else if (map.containsKey("coverImagePrefix") &&
        (map["coverImagePrefix"] is String) &&
        map.containsKey("coverImageData") &&
        map['coverImageData'] is List) {
      return '${map['coverImagePrefix'] as String},${base64Encode(map['coverImageData'] as List<int>)}';
    }
    return "";
  }

  static bool getHasThumbFromMap(Map<String, Object?> map) {
    // workaround as ttu sends hasThumb as bool but database returns hasThumb as int
    if (map.containsKey("hasThumb") && map["hasThumb"] is int) {
      return map['hasThumb'] == 1 ? true : false;
    } else if (map.containsKey("hasThumb") && map["hasThumb"] is bool) {
      return map['hasThumb'] as bool;
    } else {
      bool hasCoverImageString = map.containsKey("coverImage") &&
          map["coverImage"] is String &&
          (map["coverImage"] as String).isNotEmpty;
      bool hasCoverImageData = map.containsKey("coverImagePrefix") &&
          (map["coverImagePrefix"] is String);
      return hasCoverImageString || hasCoverImageData;
    }
  }

  // parse for ttu
  Map<String, dynamic> toMap() {
    var a = {
      'id': id,
      'title': title,
      'authorIdentifier': authorIdentifier,
      'elementHtml': elementHtml,
      'styleSheet': styleSheet,
      'playBackPositionInMs': playBackPositionInMs,
      'sections': sections?.map((section) => section.toMap()).toList(),
      'blobMap': blobMap,
      'coverImage': coverImage,
      'hasThumb': coverImage?.isNotEmpty ?? false
    };
    return a;
  }

  String get uniqueKey => '$title/$authorIdentifier';

  String get mediaIdentifier => contentUrl != null
      ? contentUrl!
      : '${LocalAssetsServerManager().getAssetUrl()}/b.html?id=$id';

  int get duration => (bookmark?.exploredCharCount == null ||
          bookmark?.progress == null ||
          bookmark?.progress == 0)
      ? 1
      : (bookmark!.exploredCharCount! ~/ bookmark!.progress!);

  int get totalCharacters => (sections != null && sections!.isNotEmpty)
      ? sections!.fold(0, (sum, section) => sum + (section.characters ?? 0))
      : 0;

  int? get hasThumbInt => hasThumb != null ? (hasThumb! ? 1 : 0) : null;

  String? get coverImagePrefix => coverImage?.split(',').first;

  Uint8List? get coverImageData =>
      coverImage != null ? base64Decode(coverImage!.split(',').last) : null;

  Map<String, String> get blobMap {
    if (blobs == null) {
      return {};
    }
    return {
      for (var blob in blobs!) blob.key: blob.base64Data ?? "",
    };
  }

  String get originalHtmlContent =>
      (elementHtmlBackup != null && elementHtmlBackup!.isNotEmpty)
          ? elementHtmlBackup!
          : elementHtml ?? "";

  bool get isHaveAudio => audioBookFiles != null && audioBookFiles!.isHaveAudio;

  bool get isHaveSubtitles =>
      audioBookFiles != null && audioBookFiles!.isHaveSubtitles;

  ImageProvider<Object> getDisplayThumbnail() {
    if (imageUrl != null) {
      return CachedNetworkImageProvider(imageUrl!);
    }

    if (coverImage == null || coverImage!.isEmpty) {
      return MemoryImage(kTransparentImage);
    }

    UriData data = Uri.parse(coverImage!).data!;

    /// A cached version of [MemoryImage] so that the image does not reload
    /// on every revisit
    return CacheImageProvider(uniqueKey, data.contentAsBytes());
  }

  void clearMatchesData() {
    matchedSubtitles = null;
  }

  void clearAudioData() {
    audioBookFiles?.audioFiles = [];
    audioFileMetadata = null;
    playBackPositionInMs = null;
    clearMatchesData();
  }

  void clearSubtitlesData() {
    audioBookFiles?.subtitleFiles = [];
    subtitlesData = null;
    clearMatchesData();
  }
}
