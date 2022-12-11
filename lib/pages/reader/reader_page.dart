import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/browser_provider.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/payment_provider.dart';
import 'package:immersion_reader/widgets/my_books/browser_catalog.dart';
import 'package:immersion_reader/widgets/my_books/my_books_widget.dart';
import 'package:local_assets_server/local_assets_server.dart';

class ReaderPage extends StatefulWidget {
  final BrowserProvider? browserProvider;
  final LocalAssetsServer? localAssetsServer;
  final PaymentProvider paymentProvider;
  final DictionaryProvider dictionaryProvider;
  const ReaderPage(
      {super.key,
      required this.browserProvider,
      required this.paymentProvider,
      required this.localAssetsServer,
      required this.dictionaryProvider});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MyBooksWidget(
        dictionaryProvider: widget.dictionaryProvider,
        localAssetsServer: widget.localAssetsServer,
      ),
      // GestureDetector(onTap: ()=>_requestPurchase("immersion_reader_plus"), )
      BrowserCatalog(
          paymentProvider: widget.paymentProvider,
          browserProvider: widget.browserProvider!,
          dictionaryProvider: widget.dictionaryProvider)
    ]);
  }
}
