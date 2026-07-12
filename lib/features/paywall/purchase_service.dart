import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/settings.dart';

/// The single Play Store product: one-time, non-consumable Pro unlock.
/// Must match the product ID created in Play Console → Monetize → Products.
const kProProductId = 'nisteia_pro';

const _kProKey = 'proUnlocked';

/// Whether the user owns Pro. `ref.watch(proProvider)` anywhere in the UI.
///
/// Direct Google Play Billing via the official `in_app_purchase` plugin —
/// no RevenueCat (decision log 2026-07-12). The entitlement is cached in
/// SharedPreferences for instant startup and re-synced from Play by the
/// silent [InAppPurchase.restorePurchases] on every launch, so a reinstall
/// or new device recovers Pro automatically.
final proProvider = StateNotifierProvider<PurchaseService, bool>(
  (ref) => PurchaseService(ref.watch(sharedPreferencesProvider)),
);

class PurchaseService extends StateNotifier<bool> {
  PurchaseService(this._prefs, {InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance,
        super(_prefs.getBool(_kProKey) ?? false) {
    _init();
  }

  final SharedPreferences _prefs;
  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _storeAvailable = false;

  Future<void> _init() async {
    // Billing exists only on the stores; web/desktop (and widget tests, where
    // no platform channel is registered) keep the cached value.
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    try {
      _storeAvailable = await _iap.isAvailable();
      if (!_storeAvailable) return;
      _sub = _iap.purchaseStream.listen(_onPurchases, onError: (Object _) {});
      // Silent on Android; keeps the entitlement true across reinstalls.
      await _iap.restorePurchases();
    } catch (_) {
      _storeAvailable = false; // MissingPluginException in tests, etc.
    }
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.productID == kProProductId &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        _setPro(true);
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  Future<void> _setPro(bool value) async {
    if (state != value) {
      state = value;
      await _prefs.setBool(_kProKey, value);
    }
  }

  /// Launches the Play purchase flow. Returns false when the store is not
  /// available (emulator without Play, web preview, product not configured) —
  /// the UI shows its "not yet" message in that case. The actual result
  /// arrives asynchronously via [proProvider].
  Future<bool> buy() async {
    if (!_storeAvailable) return false;
    try {
      final resp = await _iap.queryProductDetails(const {kProProductId});
      if (resp.productDetails.isEmpty) return false;
      return _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: resp.productDetails.first),
      );
    } catch (_) {
      return false;
    }
  }

  /// Re-queries Play for past purchases (the mandatory "Restore purchase"
  /// button). Returns false when the store is unavailable.
  Future<bool> restore() async {
    if (!_storeAvailable) return false;
    try {
      await _iap.restorePurchases();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
