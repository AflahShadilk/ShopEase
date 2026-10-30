import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/shop_product.dart';
import '../../services/product_service.dart';

class ProductFormController extends GetxController {
  ProductFormController({required this.service, this.product});

  final ProductService service;
  final ShopProduct? product;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final category = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();
  final imageUrl = TextEditingController();
  final isActive = true.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final current = product;
    if (current == null) return;
    name.text = current.name;
    description.text = current.description;
    category.text = current.category;
    price.text = current.price.toString();
    stock.text = current.stock.toString();
    imageUrl.text = current.imageUrl;
    isActive.value = current.isActive;
  }

  Future<void> save() async {
    if (isSaving.value || !(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      await service.saveProduct(
        existing: product,
        name: name.text.trim(),
        description: description.text.trim(),
        category: category.text.trim(),
        price: int.parse(price.text.trim()),
        stock: int.parse(stock.text.trim()),
        imageUrl: imageUrl.text.trim(),
        isActive: isActive.value,
      );
      Get.back();
      Get.snackbar('Saved', 'Your product has been saved.');
    } catch (_) {
      Get.snackbar(
          'Save failed', 'Check the internet, your admin role and rules.');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    description.dispose();
    category.dispose();
    price.dispose();
    stock.dispose();
    imageUrl.dispose();
    super.onClose();
  }
}
