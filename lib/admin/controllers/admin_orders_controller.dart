import 'dart:async';

import 'package:get/get.dart';

import '../../models/shop_order.dart';
import '../../services/order_service.dart';
import '../../shared/controllers/shop_session_controller.dart';

class AdminOrdersController extends GetxController {
  AdminOrdersController({required this.service, required this.session});

  final OrderService service;
  final ShopSessionController session;
  final orders = <ShopOrder>[].obs;
  final loading = false.obs;
  final working = false.obs;
  final error = ''.obs;
  StreamSubscription<List<ShopOrder>>? _subscription;
  Worker? _profileWorker;

  @override
  void onInit() {
    super.onInit();
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
    if (session.profile.value?['role'] != 'admin') return;
    loading.value = true;
    _subscription = service.watchAdminOrders().listen((value) {
      orders.assignAll(value);
      loading.value = false;
    }, onError: (Object _) {
      error.value = 'Unable to load orders. Check your admin permissions.';
      loading.value = false;
    });
  }

  Future<void> changeStatus(ShopOrder order, String next) async {
    if (working.value) return;
    working.value = true;
    try {
      await service.updateStatus(order.id, next);
      Get.snackbar('Order updated', 'Status changed to $next');
    } catch (_) {
      Get.snackbar('Unable to update', 'Check your connection and rules.');
    } finally {
      working.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _profileWorker?.dispose();
    super.onClose();
  }
}
