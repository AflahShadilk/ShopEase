import 'dart:async';

import 'package:get/get.dart';

import '../../models/shop_product.dart';
import 'customer_cart_controller.dart';
import '../../services/product_service.dart';
import '../../shared/controllers/shop_session_controller.dart';

class CustomerCatalogController extends GetxController {
  CustomerCatalogController({required this.service, required this.session});

  final ProductService service;
  final ShopSessionController session;
  final products = <ShopProduct>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  Worker? _profileWorker;
  StreamSubscription<List<ShopProduct>>? _productSubscription;

  @override
  void onInit() {
    super.onInit();
    _profileWorker =
        ever<Map<String, dynamic>?>(session.profile, _watchForRole);
    _watchForRole(session.profile.value);
  }

  void _watchForRole(Map<String, dynamic>? profile) {
    _productSubscription?.cancel();
    _productSubscription = null;
    products.clear();
    error.value = '';
    isLoading.value = false;

    if (profile?['role'] != 'customer') return;

    isLoading.value = true;
    _productSubscription = service.watchCustomerProducts().listen(
      (items) {
        products.assignAll(items);
        Get.find<CustomerCartController>().syncProducts(items);
        isLoading.value = false;
      },
      onError: (Object _) {
        error.value =
            'Could not load products. Check internet and Firestore rules.';
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _profileWorker?.dispose();
    _productSubscription?.cancel();
    super.onClose();
  }
}
