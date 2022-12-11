import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

List<String> _productLists = ['immersion_reader_plus'];

class PaymentProvider {
  StreamSubscription? _purchaseUpdatedSubscription;
  StreamSubscription? _purchaseErrorSubscription;
  StreamSubscription? _conectionSubscription;
  // String _platformVersion = 'Unknown';
  List<IAPItem>? _items;
  List<PurchasedItem>? _purchases;
  bool hasConnectionError = false;

  PaymentProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<PaymentProvider> create() async {
    PaymentProvider provider = PaymentProvider._create();
    var result = await FlutterInappPurchase.instance.initialize();
    provider._conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      debugPrint('connected: $connected');
    });

    provider._purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      debugPrint('purchase-updated: $productItem');
    });

    provider._purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      debugPrint('purchase-error: $purchaseError');
    });
    return provider;
  }

  Future<void> invokePurchaseOrProceed(
      String productName, VoidCallback callback) async {
        hasConnectionError = false;
    PurchasedItem? purchaseItem = await getPurchaseByString(productName);
    if (hasConnectionError) {
      return;
    }
    if (purchaseItem == null) {
      IAPItem? item = await getProductByString(productName);
      if (item != null) {
        FlutterInappPurchase.instance.requestPurchase(item.productId!);
      }
    } else {
      callback();
    }
  }

  Future<IAPItem?> getProductByString(String productName) async {
    _items ??= await FlutterInappPurchase.instance.getProducts(_productLists);
    return _items!.firstWhereOrNull((item) => item.productId == productName);
  }

  Future<PurchasedItem?> getPurchaseByString(String productName) async {
    _purchases = await _getPurchases();
    if (_purchases != null) {
    return _purchases!
        .firstWhereOrNull((purchase) => purchase.productId == productName);
    }
  }

  Future<List<PurchasedItem>?> _getPurchases() async {
    if (_purchases != null) {
      return _purchases!;
    }
    try {
      _purchases = await FlutterInappPurchase.instance.getAvailablePurchases();
    }  catch (err) {
      debugPrint(err.toString());
      hasConnectionError = true;
      return null;
    }
    return _purchases!;
  }

  void dispose() {
    if (_conectionSubscription != null) {
      _conectionSubscription!.cancel();
      _conectionSubscription = null;
    }
  }
}
