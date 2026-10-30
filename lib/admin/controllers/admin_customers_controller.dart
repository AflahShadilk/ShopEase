import 'dart:async';

import 'package:get/get.dart';

import '../../models/shop_customer.dart';
import '../../services/customer_directory_service.dart';
import '../../shared/controllers/shop_session_controller.dart';

class AdminCustomersController extends GetxController {
  AdminCustomersController({required this.service, required this.session});

  final CustomerDirectoryService service;
  final ShopSessionController session;
  final customers = <ShopCustomer>[].obs;
  final loading = false.obs;
  final error = ''.obs;
  final search = ''.obs;

  StreamSubscription<List<ShopCustomer>>? _subscription;
  Worker? _roleWorker;

  List<ShopCustomer> get filteredCustomers {
    final query = search.value.trim().toLowerCase();
    if (query.isEmpty) return customers.toList();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _roleWorker = ever<Map<String, dynamic>?>(session.profile, (_) => _watch());
    _watch();
  }

  void _watch() {
    _subscription?.cancel();
    _subscription = null;
    customers.clear();
    error.value = '';
    loading.value = false;
    if (session.profile.value?['role'] != 'admin') return;

    loading.value = true;
    _subscription = service.watchCustomers().listen(
      (items) {
        customers.assignAll(items);
        loading.value = false;
      },
      onError: (Object _) {
        error.value =
            'Unable to load customer profiles. Check Firestore rules.';
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
