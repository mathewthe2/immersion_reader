import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/common/icon_list_tile.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:immersion_reader/pages/settings/about/thanks_page.dart';
import 'package:url_launcher/url_launcher.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('About')),
        child: SafeArea(
            child: CupertinoListSection(children: [
          IconListTile(
            title: "@MathewChan",
            iconData: FontAwesomeIcons.twitter,
            iconBackgroundColor: CupertinoColors.systemBlue,
            onTap: () {
              launchUrl(Uri.parse("https://twitter.com/MathewChan10"));
            },
          ),
          IconListTile(
            title: "Thanks to",
            iconData: FontAwesomeIcons.solidFaceLaugh,
            iconBackgroundColor: CupertinoColors.systemGreen,
            onTap: () {
              Navigator.push(context, SwipeablePageRoute(builder: (context) {
                return const ThanksPage();
              }));
            },
          ),
          IconListTile(
            title: "Terms & Privacy Policy",
            iconData: CupertinoIcons.hand_raised_fill,
            iconBackgroundColor: CupertinoColors.systemBlue,
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: _modalBuilder,
              );
            },
          ),
          IconListTile(
            title: "Bug Reports",
            iconData: FontAwesomeIcons.bug,
            iconBackgroundColor: CupertinoColors.systemRed,
            onTap: () {
              launchUrl(Uri.parse(
                  "https://github.com/mathewthe2/immersion_reader/issues"));
            },
          ),
          IconListTile(
            title: "Contact",
            iconData: CupertinoIcons.at,
            iconBackgroundColor: CupertinoColors.systemBlue,
            onTap: () {
              launchUrl(Uri.parse("https://www.immersionkit.com/creators"));
            },
          ),
        ])));
  }

  Widget _modalBuilder(BuildContext context) {
    return CupertinoActionSheet(
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          child: const Text('Terms of Use'),
          onPressed: () {
            launchUrl(Uri.parse("https://reader.immersionkit.com/terms/"));
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Privacy Policy'),
          onPressed: () {
            launchUrl(
                Uri.parse("https://reader.immersionkit.com/privacypolicy/"));
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    //   },
    // );
  }
}
