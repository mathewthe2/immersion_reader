import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/utils/cached_memory_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class Book {
  String title;
  String? base64Image;
  String? imageUrl;
  String? author;
  String? authorIdentifier;
  String? mediaIdentifier;
  int? position;
  int? duration;
  Book(
      {required this.title,
      this.base64Image,
      this.imageUrl,
      this.author,
      this.authorIdentifier,
      this.mediaIdentifier,
      this.position,
      this.duration});

  String get uniqueKey => '$title/$authorIdentifier';

  ImageProvider<Object> getDisplayThumbnail() {
    if (imageUrl != null) {
      return CachedNetworkImageProvider(imageUrl!);
    }

    if (base64Image == null) {
      return MemoryImage(kTransparentImage);
    }

    UriData data = Uri.parse(base64Image!).data!;

    /// A cached version of [MemoryImage] so that the image does not reload
    /// on every revisit
    return CacheImageProvider(uniqueKey, data.contentAsBytes());
  }
}
