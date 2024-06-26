import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/payment_provider.dart';
import 'package:immersion_reader/widgets/common/padding_bottom.dart';
import 'package:immersion_reader/widgets/my_books/browser_catalog.dart';
import 'package:immersion_reader/widgets/my_books/my_books_widget.dart';

class ReaderPage extends StatefulWidget {
  final PaymentProvider paymentProvider;
  const ReaderPage({super.key, required this.paymentProvider});

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
          SliverList(
              delegate: SliverChildListDelegate([
            const MyBooksWidget(),
            // GestureDetector(onTap: ()=>_requestPurchase("immersion_reader_plus"), )
            if (Platform.isIOS)
              BrowserCatalog(paymentProvider: widget.paymentProvider),
            const PaddingBottom()
          ]))
        ]));
  }
}
