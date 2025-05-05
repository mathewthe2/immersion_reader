import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';

class PlaybackSpeedPicker extends StatefulWidget {
  const PlaybackSpeedPicker({super.key});

  @override
  State<PlaybackSpeedPicker> createState() => _PlaybackSpeedPickerState();
}

class _PlaybackSpeedPickerState extends State<PlaybackSpeedPicker> {
  static const List<double> playbackRates = [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0];
  static const double _kItemExtent = 32.0;
  int selectedIndex = binarySearch(
      playbackRates, AudioPlayerManager().audioService.getPlaybackRate());

  @override
  Widget build(BuildContext context) {
    void showDialog(Widget child) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
          child: SafeArea(top: false, child: child),
        ),
      );
    }

    return GestureDetector(
        onTap: () => showDialog(
              CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: _kItemExtent,
                scrollController:
                    FixedExtentScrollController(initialItem: selectedIndex),
                onSelectedItemChanged: (int newIndex) {
                  AudioPlayerManager()
                      .audioService
                      .setPlaybackRate(playbackRates[newIndex]);
                  setState(() {
                    selectedIndex = newIndex;
                  });
                },
                children:
                    playbackRates.map((rate) => Text(rate.toString())).toList(),
              ),
            ),
        child: Column(
          children: [
            AppText("Speed: ${playbackRates[selectedIndex]}",
                style: TextStyle(fontSize: 12))
          ],
        ));
  }
}
