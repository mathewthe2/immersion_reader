import 'package:audio_service/audio_service.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_service_handler.dart';

// Singleton to ensure only one copy of audioservice is initiated
class AudioPlayerHandler {
  late AudioServiceHandler audioServiceHandler;
  bool isInitialized = false;

  static final AudioPlayerHandler _singleton = AudioPlayerHandler._internal();
  AudioPlayerHandler._internal();

  factory AudioPlayerHandler.create(AudioServiceHandler audioServiceHandler) {
    _singleton.audioServiceHandler = audioServiceHandler;
    _singleton.isInitialized = true;
    return _singleton;
  }

  factory AudioPlayerHandler() => _singleton;

  Future<void> resetAudioHandler() async {
    audioServiceHandler.setup();
  }

  static Future<void> setup() async {
    if (AudioPlayerHandler().isInitialized) {
      AudioPlayerHandler().resetAudioHandler();
      return;
    }
    // called once when app is initialized
    final audioHandler = await AudioService.init(
      builder: () {
        final audioServiceHandler = AudioServiceHandler();
        audioServiceHandler.setup();
        return audioServiceHandler;
      },
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.immersionreader.channel.audio',
        androidNotificationChannelName: 'Immersion Reader',
      ),
    );
    AudioPlayerHandler.create(audioHandler);
  }
}
