import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

// https://stackoverflow.com/questions/67963713/how-to-cache-memory-image-using-image-memory-or-memoryimage-flutter
// https://gist.github.com/darmawan01/9be266df44594ea59f07032e325ffa3b

class CacheImageProvider extends ImageProvider<CacheImageProvider> {
  final String tag; //the cache id use to get cache
  final Uint8List img; //the bytes of image to cache

  CacheImageProvider(this.tag, this.img);

  @override
  ImageStreamCompleter loadBuffer(CacheImageProvider key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
      debugLabel: tag,
      informationCollector: () sync* {
        yield ErrorDescription('Tag: $tag');
      },
    );
  }

  Future<Codec> _loadAsync(DecoderBufferCallback decode) async {
    // the DefaultCacheManager() encapsulation, it get cache from local storage.
    final Uint8List bytes = img;

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(this);
      throw StateError('$tag is empty and cannot be loaded as an image.');
    }
    final buffer = await ImmutableBuffer.fromUint8List(bytes);
    return await decode(buffer);
  }

  @override
  Future<CacheImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    bool res = other is CacheImageProvider && other.tag == tag;
    return res;
  }

  @override
  int get hashCode => tag.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CacheImageProvider')}("$tag")';
}
