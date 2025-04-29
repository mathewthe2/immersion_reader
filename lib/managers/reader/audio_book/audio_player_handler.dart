import 'package:audio_service/audio_service.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_service_handler.dart';

class AudioPlayerHandler {
  late AudioServiceHandler audioServiceHandler;

  static final AudioPlayerHandler _singleton = AudioPlayerHandler._internal();
  AudioPlayerHandler._internal();

  factory AudioPlayerHandler.create(AudioServiceHandler audioServiceHandler) {
    _singleton.audioServiceHandler = audioServiceHandler;
    return _singleton;
  }

  factory AudioPlayerHandler() => _singleton;

  // called once when app is initialized
  static Future<void> setup() async {
    final audioHandler = await AudioService.init(
      builder: () => AudioServiceHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.immersionreader.channel.audio',
        androidNotificationChannelName: 'Immersion Reader',
      ),
    );
    AudioPlayerHandler.create(audioHandler);
  }
}
