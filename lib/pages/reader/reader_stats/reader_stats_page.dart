import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/profile/profile_content_stats.dart';
import 'package:immersion_reader/pages/reader/reader_stats/book_stats_row.dart';
import 'package:immersion_reader/providers/profile_provider.dart';

class ReaderStatsPage extends StatefulWidget {
  final ProfileProvider profileProvider;
  const ReaderStatsPage({super.key, required this.profileProvider});

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
    var contentStats = await widget.profileProvider.getProfileContentStats();
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
      return Column(children: [
        ...profileContentStats!
            .map((ProfileContentStats stat) => Column(children: [
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: BookStatsRow(contentStats: stat))
                ]))
      ]);
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
