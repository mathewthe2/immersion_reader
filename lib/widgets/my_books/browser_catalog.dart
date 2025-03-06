import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/pages/browser.dart';
import 'package:immersion_reader/providers/payment_provider.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BrowserCatalog extends StatefulWidget {
  final PaymentProvider paymentProvider;
  const BrowserCatalog({super.key, required this.paymentProvider});

  @override
  State<BrowserCatalog> createState() => _BrowserCatalogState();
}

class _BrowserCatalogState extends State<BrowserCatalog> {
  void onExitReader() {
    PopupDictionary.create().dismissPopupDictionary();
  }

  Widget headlineWidget(
      {required String title,
      String? subtitle,
      required IconData iconData,
      required Color textColor}) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 10, 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    FaIcon(
                      iconData,
                      color: textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(title,
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(subtitle!,
                        style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                const CupertinoDynamicColor.withBrightness(
                                    color: CupertinoColors.systemPurple,
                                    darkColor: Color(0xFFDCD8FF)),
                                context),
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ]),
                  GestureDetector(
                      onTap: () {
                        widget.paymentProvider.invokePurchaseOrProceed(
                            "immersion_reader_plus",
                            () => Navigator.of(context, rootNavigator: true)
                                .push(SwipeablePageRoute(
                                    canOnlySwipeFromEdge: true,
                                    backGestureDetectionWidth: 25,
                                    builder: (context) {
                                      return const Browser();
                                    }))
                                .then((_) => onExitReader()));
                      },
                      child: Text('Open', style: TextStyle(color: textColor)))
                ])));
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black, darkColor: CupertinoColors.white),
        context);
    return Column(children: [
      headlineWidget(
          title: "Browser",
          subtitle: "PLUS",
          iconData: FontAwesomeIcons.globe,
          textColor: textColor),
      const SizedBox(height: 40) // margin for small screens
    ]);
  }
}
