import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/shop_product.dart';
import '../../services/product_image_service.dart';
import '../../services/product_service.dart';

class ProductFormController extends GetxController {
  ProductFormController({
    required this.service,
    this.product,
    ProductImageService? imageService,
  }) : imageService = imageService ?? ProductImageService();

  final ProductService service;
  final ShopProduct? product;
  final ProductImageService imageService;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final category = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();
  final imageUrl = TextEditingController();
  final isActive = true.obs;
  final isSaving = false.obs;
  final isPicking = false.obs;
  final selectedImage = Rxn<ProductImageSelection>();

  @override
  void onInit() {
    super.onInit();
    final current = product;
    if (current == null) {
      return;
    }
    name.text = current.name;
    description.text = current.description;
    category.text = current.category;
    price.text = current.price.toString();
    stock.text = current.stock.toString();
    imageUrl.text = current.imageUrl;
    isActive.value = current.isActive;
  }

  Future<void> pickImage() async {
    if (isPicking.value || isSaving.value) {
      return;
    }
    isPicking.value = true;
    try {
      final file = await imageService.pick();
      if (file != null) {
        selectedImage.value = file;
      }
    } catch (error) {
      Get.snackbar('Image not selected', error.toString());
    } finally {
      isPicking.value = false;
    }
  }

  void clearPickedImage() => selectedImage.value = null;

  Future<void> save() async {
    if (isSaving.value || !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    isSaving.value = true;
    UploadedProductImage? uploaded;
    try {
      final picked = selectedImage.value;
      if (picked != null) {
        uploaded = await imageService.upload(picked);
      }
      await service.saveProduct(
        existing: product,
        name: name.text.trim(),
        description: description.text.trim(),
        category: category.text.trim(),
        price: int.parse(price.text.trim()),
        stock: int.parse(stock.text.trim()),
        imageUrl: uploaded?.url ?? imageUrl.text.trim(),
        isActive: isActive.value,
      );
      selectedImage.value = null;
      Get.back();
      Get.snackbar('Saved', 'Your product has been saved.');
    } catch (error) {
      if (uploaded != null) {
        try {
          await imageService.deleteUploaded(uploaded.path);
        } catch (_) {
          // Cleanup is best effort if the Firestore write fails.
        }
      }
      Get.snackbar('Save failed',
          'Check Storage access, admin permissions or Firestore. $error');
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
