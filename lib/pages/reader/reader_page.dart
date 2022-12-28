import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/browser_provider.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/payment_provider.dart';
import 'package:immersion_reader/providers/profile_provider.dart';
import 'package:immersion_reader/widgets/my_books/browser_catalog.dart';
import 'package:immersion_reader/widgets/my_books/my_books_widget.dart';
import 'package:local_assets_server/local_assets_server.dart';

class ReaderPage extends StatefulWidget {
  final BrowserProvider? browserProvider;
  final LocalAssetsServer? localAssetsServer;
  final ProfileProvider profileProvider;
  final PaymentProvider paymentProvider;
  final DictionaryProvider dictionaryProvider;
  const ReaderPage(
      {super.key,
      required this.browserProvider,
      required this.paymentProvider,
      required this.profileProvider,
      required this.localAssetsServer,
      required this.dictionaryProvider});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemBackground,
            darkColor: CupertinoColors.black),
        context);
    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: CustomScrollView(slivers: [
          (CupertinoSliverNavigationBar(
              largeTitle: const Text('Reader'),
              backgroundColor: backgroundColor,
              border: const Border())),
          SliverFillRemaining(
              child: Container(
                  color: backgroundColor,
                  child: SafeArea(
                      child: SingleChildScrollView(
                          child: Column(children: [
                    const SizedBox(height: 20),
                    MyBooksWidget(
                        dictionaryProvider: widget.dictionaryProvider,
                        localAssetsServer: widget.localAssetsServer,
                        profileProvider: widget.profileProvider),
                    // GestureDetector(onTap: ()=>_requestPurchase("immersion_reader_plus"), )
                    BrowserCatalog(
                        paymentProvider: widget.paymentProvider,
                        browserProvider: widget.browserProvider!,
                        dictionaryProvider: widget.dictionaryProvider)
                  ])))))
        ]));
  }
}
