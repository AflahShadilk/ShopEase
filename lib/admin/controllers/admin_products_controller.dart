import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/shop_product.dart';
import '../../services/product_service.dart';
import '../../shared/controllers/shop_session_controller.dart';

class AdminProductsController extends GetxController {
  AdminProductsController({required this.service, required this.session});

  final ProductService service;
  final ShopSessionController session;
  final products = <ShopProduct>[].obs;
  final isLoading = false.obs;
  final isWorking = false.obs;
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

    if (profile?['role'] != 'admin') return;

    isLoading.value = true;
    _productSubscription = service.watchAdminProducts().listen(
      (items) {
        products.assignAll(items);
        isLoading.value = false;
      },
      onError: (Object _) {
        error.value = 'Could not load products. Verify admin access and rules.';
        isLoading.value = false;
      },
    );
  }

  Future<void> changeVisibility(ShopProduct product) async {
    isWorking.value = true;
    try {
      await service.setActive(product, !product.isActive);
      Get.snackbar('Updated', 'Product visibility changed.');
    } catch (_) {
      Get.snackbar('Not saved', 'Check your admin role and Firestore rules.');
    } finally {
      isWorking.value = false;
    }
  }

  Future<void> delete(ShopProduct product) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete this product?'),
        content: Text('Delete "${product.name}" permanently?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    isWorking.value = true;
    try {
      await service.deleteProduct(product);
      Get.snackbar('Deleted', 'Product removed from Firestore.');
    } catch (_) {
      Get.snackbar(
          'Not deleted', 'Check your admin access and Firestore rules.');
    } finally {
      isWorking.value = false;
    }
  }

  @override
  void onClose() {
    _profileWorker?.dispose();
    _productSubscription?.cancel();
    super.onClose();
  }
}
