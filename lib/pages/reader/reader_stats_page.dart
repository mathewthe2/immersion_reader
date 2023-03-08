import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/profile/profile_content_stats.dart';
import 'package:immersion_reader/managers/profile/profile_manager.dart';
import 'package:immersion_reader/widgets/reader/reader_stats/book_stats_row.dart';

class ReaderStatsPage extends StatefulWidget {
  const ReaderStatsPage({super.key});

  @override
  State<ReaderStatsPage> createState() => _ReaderStatsPageState();
}

class _ReaderStatsPageState extends State<ReaderStatsPage> {
  List<ProfileContentStats>? profileContentStats;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    var contentStats = await ProfileManager().getProfileContentStats();
    setState(() {
      profileContentStats = contentStats;
    });
  }

  Widget readTime() {
    if (profileContentStats == null) {
      return const Text('loading');
    } else if (profileContentStats!.isEmpty) {
      return const Text('Nothing to see here. Start reading!');
    } else {
      profileContentStats!.sort((a, b) =>
          b.profileContent.lastOpened.compareTo(a.profileContent.lastOpened));
      return SingleChildScrollView(
          child: Column(children: [
        ...profileContentStats!
            .map((ProfileContentStats stat) => Column(children: [
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: BookStatsRow(contentStats: stat))
                ])),
        const SizedBox(height: 40)
      ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Reader Stats')),
        child: SafeArea(child: readTime()));
  }
}
