import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:immersion_reader/utils/internet_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> _productLists = ['immersion_reader_plus'];

class PaymentProvider {
  SharedPreferences? _sharedPreferences;
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

  static Future<PaymentProvider> create(
      SharedPreferences sharedPreferences) async {
    PaymentProvider provider = PaymentProvider._create();
    var result = await FlutterInappPurchase.instance.initialize();
    provider._sharedPreferences = sharedPreferences;
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

  String _formatProductString(String productId) {
    return 'purchase_$productId';
  }

  Future<void> invokePurchaseOrProceed(
      String productName, VoidCallback callback) async {
    // check local preferences
    if (_sharedPreferences != null && (_sharedPreferences!.getBool(_formatProductString(productName)) ?? false)) {
      callback();
      return;
    }
    // check online
    bool hasInternetConnection = await InternetUtils.hasInternetConnection();
    if (!hasInternetConnection){
      // return status here
      debugPrint('offline');
      return;
    }
    debugPrint('online');
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
    return null;
  }

  Future<List<PurchasedItem>?> _getPurchases() async {
    if (_purchases != null) {
      return _purchases!;
    }
    try {
      _purchases = await FlutterInappPurchase.instance.getAvailablePurchases();
      persistPurchases(_purchases);
    } catch (err) {
      debugPrint(err.toString());
      hasConnectionError = true;
      return null;
    }
    return _purchases!;
  }

  void persistPurchases(List<PurchasedItem>? purchases) {
    if (_sharedPreferences == null || purchases == null) {
      return;
    }
    for (PurchasedItem purchaseItem in purchases) {
      _sharedPreferences!.setBool(_formatProductString(purchaseItem.productId!), true);
    }
  }

  void dispose() {
    if (_conectionSubscription != null) {
      _conectionSubscription!.cancel();
      _conectionSubscription = null;
    }
  }
}
