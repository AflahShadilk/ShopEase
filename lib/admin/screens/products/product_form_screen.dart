import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/shop_editor_layout.dart';
import '../../../core/widgets/shop_button.dart';
import '../../../core/widgets/shop_text_field.dart';
import '../../controllers/product_form_controller.dart';

class ProductFormScreen extends GetView<ProductFormController> {
  const ProductFormScreen({super.key});

  String? _requiredText(String? text) {
    if (text == null || text.trim().length < 2) {
      return 'Enter at least 2 characters';
    }
    return null;
  }

  String? _nonNegativeInt(String? text) {
    final value = int.tryParse(text?.trim() ?? '');

    if (value == null || value < 0) {
      return 'Enter a whole number (0 or more)';
    }
    return null;
  }

  String? _positivePrice(String? text) {
    final value = int.tryParse(text?.trim() ?? '');

    if (value == null || value <= 0) {
      return 'Enter a whole rupee amount above 0';
    }
    return null;
  }

  String? _optionalImageUrl(String? text) {
    if (text == null || text.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(text.trim());

    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return 'Use a valid HTTPS image URL';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ShopEditorLayout(
      title: controller.product == null
          ? 'Add a standout item.'
          : 'Edit the details.',
      subtitle: 'Everything you save appears in Cloud Firestore.',
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            ShopTextField(
              label: 'Product name',
              hint: 'Example: Citrus Canvas Tote',
              icon: Icons.shopping_bag_outlined,
              controller: controller.name,
              validator: _requiredText,
            ),
            const SizedBox(height: 14),
            ShopTextField(
              label: 'Description',
              hint: 'What makes this product special?',
              icon: Icons.notes_outlined,
              controller: controller.description,
              validator: _requiredText,
            ),
            const SizedBox(height: 14),
            ShopTextField(
              label: 'Category',
              hint: 'Accessories',
              icon: Icons.category_outlined,
              controller: controller.category,
              validator: _requiredText,
            ),
            const SizedBox(height: 14),
            ShopTextField(
              label: 'Price in rupees',
              hint: '799',
              icon: Icons.currency_rupee,
              controller: controller.price,
              keyboardType: TextInputType.number,
              validator: _positivePrice,
            ),
            const SizedBox(height: 14),
            ShopTextField(
              label: 'Stock quantity',
              hint: '12',
              icon: Icons.inventory_2_outlined,
              controller: controller.stock,
              keyboardType: TextInputType.number,
              validator: _nonNegativeInt,
            ),
            const SizedBox(height: 14),
            ShopTextField(
              label: 'Image URL (optional)',
              hint: 'https://example.com/item.jpg',
              icon: Icons.image_outlined,
              controller: controller.imageUrl,
              keyboardType: TextInputType.url,
              validator: _optionalImageUrl,
            ),
            const SizedBox(height: 12),
            Obx(() => SwitchListTile.adaptive(
                  title: const Text('Show in customer catalog'),
                  value: controller.isActive.value,
                  onChanged: (value) => controller.isActive.value = value,
                )),
            const SizedBox(height: 24),
            Obx(() => ShopButton(
                  label: controller.product == null
                      ? 'Create product'
                      : 'Save changes',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.isSaving.value ? null : controller.save,
                )),
          ],
        ),
      ),
    );
  }
}
