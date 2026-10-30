import 'dart:async';

import 'package:get/get.dart';

import '../../models/shop_order.dart';
import '../../services/customer_directory_service.dart';
import '../../shared/controllers/shop_session_controller.dart';

class AdminCustomerOrdersController extends GetxController {
  AdminCustomerOrdersController({
    required this.service,
    required this.session,
    required this.customerId,
  });

  final CustomerDirectoryService service;
  final ShopSessionController session;
  final String customerId;
  final orders = <ShopOrder>[].obs;
  final loading = false.obs;
  final error = ''.obs;

  StreamSubscription<List<ShopOrder>>? _subscription;
  Worker? _roleWorker;

  int get totalOrders => orders.length;
  int get completedOrders =>
      orders.where((o) => o.status == 'delivered').length;
  int get lifetimeTotal => orders
      .where((o) => o.status != 'cancelled')
      .fold<int>(0, (sum, order) => sum + order.total);

  @override
  void onInit() {
    super.onInit();
    _roleWorker = ever<Map<String, dynamic>?>(session.profile, (_) => _watch());
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
    _subscription = service.watchOrdersForCustomer(customerId).listen(
      (items) {
        orders.assignAll(items);
        loading.value = false;
      },
      onError: (Object _) {
        error.value = 'Unable to load this customer’s orders.';
        loading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _roleWorker?.dispose();
    super.onClose();
  }
}
