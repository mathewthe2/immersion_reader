import 'package:flutter/cupertino.dart';
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
          CupertinoListTile(
            title: const Text("@MathewChan"),
            onTap: () =>
                {launchUrl(Uri.parse("https://twitter.com/MathewChan10"))},
            leading: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const FaIcon(
                FontAwesomeIcons.twitter,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
            trailing: const Icon(CupertinoIcons.forward),
          ),
          CupertinoListTile(
            title: const Text("Thanks to"),
            onTap: () => {
              Navigator.push(context, SwipeablePageRoute(builder: (context) {
                return const ThanksPage();
              }))
            },
            leading: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const FaIcon(
                FontAwesomeIcons.solidFaceLaugh,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
            trailing: const Icon(CupertinoIcons.forward),
          ),
          CupertinoListTile(
            title: const Text("Terms & Privacy Policy"),
            onTap: () => showCupertinoModalPopup(
              context: context,
              builder: _modalBuilder,
            ),
            leading: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Icon(
                  size: 22,
                  CupertinoIcons.hand_raised_fill,
                  color: CupertinoColors.white),
            ),
            trailing: const Icon(CupertinoIcons.forward),
          ),
          CupertinoListTile(
            title: const Text("Bug Reports"),
            onTap: () => {
              launchUrl(Uri.parse(
                  "https://github.com/mathewthe2/immersion_reader/issues"))
            },
            leading: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.bug,
                  color: CupertinoColors.white,
                  size: 20,
                )),
            trailing: const Icon(CupertinoIcons.forward),
          ),
          CupertinoListTile(
            title: const Text("Contact"),
            onTap: () =>
                {launchUrl(Uri.parse("https://www.immersionkit.com/creators"))},
            leading: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Icon(
                  size: 22, CupertinoIcons.at, color: CupertinoColors.white),
            ),
            trailing: const Icon(CupertinoIcons.forward),
          )
        ])));
  }

  Widget _modalBuilder(BuildContext context) {
    return CupertinoActionSheet(
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          child: const Text('Terms of Use'),
          onPressed: () {
            launchUrl(Uri.parse(
                "https://mathewthe2.github.io/immersion-reader-website/terms_and_conditions.html"));
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Privacy Policy'),
          onPressed: () {
            launchUrl(Uri.parse(
                "https://mathewthe2.github.io/immersion-reader-website/privacy_policy.html"));
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
