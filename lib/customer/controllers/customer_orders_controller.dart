import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../models/shop_order.dart';
import '../../services/order_service.dart';
import '../../shared/controllers/shop_session_controller.dart';

class CustomerOrdersController extends GetxController {
  CustomerOrdersController({required this.service, required this.session});

  final OrderService service;
  final ShopSessionController session;
  final orders = <ShopOrder>[].obs;
  final loading = false.obs;
  final error = ''.obs;
  StreamSubscription<List<ShopOrder>>? _subscription;
  Worker? _userWorker;
  Worker? _profileWorker;

  @override
  void onInit() {
    super.onInit();
    _userWorker = ever<User?>(session.user, (_) => _watch());
    _profileWorker =
        ever<Map<String, dynamic>?>(session.profile, (_) => _watch());
    _watch();
  }

  void _watch() {
    _subscription?.cancel();
    _subscription = null;
    orders.clear();
    error.value = '';
    loading.value = false;
    if (session.user.value == null ||
        session.profile.value?['role'] != 'customer') {
      return;
    }
    loading.value = true;
    _subscription = service.watchMyOrders().listen((value) {
      orders.assignAll(value);
      loading.value = false;
    }, onError: (Object _) {
      error.value = 'Unable to load your orders.';
      loading.value = false;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _userWorker?.dispose();
    _profileWorker?.dispose();
    super.onClose();
  }
}
