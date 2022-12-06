import 'package:flutter/cupertino.dart';
import 'package:cupertino_lists/cupertino_lists.dart' as cupertino_lists;
import 'package:url_launcher/url_launcher.dart';
import 'package:immersion_reader/data/settings/about/thanks_data.dart';

class ThanksPage extends StatelessWidget {
  const ThanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Thanks to')),
        child: SafeArea(
            child: CustomScrollView(slivers: [
          SliverFillRemaining(
              child: Container(
                  color: CupertinoDynamicColor.resolve(
                      const CupertinoDynamicColor.withBrightness(
                          color: CupertinoColors.systemGroupedBackground,
                          darkColor: CupertinoColors.black),
                      context),
                  child: SingleChildScrollView(
                      child: Column(children: [
                    ...acknowledgements.entries.map((acknowledgement) =>
                        cupertino_lists.CupertinoListSection(
                            header: Text(acknowledgement.key),
                            children: acknowledgement.value.entries
                                .map((attribution) =>
                                    cupertino_lists.CupertinoListTile(
                                      title: Text(attribution.key),
                                      trailing: attribution.value.isNotEmpty
                                          ? const Icon(CupertinoIcons.forward)
                                          : Container(),
                                      onTap: () => {
                                        if (attribution.value.isNotEmpty)
                                          {
                                            launchUrl(
                                                Uri.parse(attribution.value))
                                          }
                                      },
                                    ))
                                .toList()))
                  ]))))
        ])));
  }
}
