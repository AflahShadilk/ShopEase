import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_button.dart';
import '../../../core/widgets/shop_checkout_layout.dart';
import '../../../core/widgets/shop_text_field.dart';
import '../../controllers/shop_checkout_controller.dart';
import '../orders/shop_orders_screen.dart';

class ShopCheckoutScreen extends GetView<ShopCheckoutController> {
  const ShopCheckoutScreen({super.key});

  Future<void> _placeOrder() async {
    if (await controller.submit()) {
      Get.off<void>(() => const ShopOrdersScreen());
      Get.snackbar('Order requested',
          'Your cash-on-delivery order is pending confirmation.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopCheckoutLayout(
      title: 'Checkout, simply.',
      subtitle: 'Delivery details for your cash-on-delivery request.',
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DELIVERY DETAILS',
                style: TextStyle(
                  color: ShopColors.dragonfruit,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                )),
            const SizedBox(height: 18),
            ShopTextField(
              label: 'Full name',
              hint: 'Your name',
              icon: Icons.person_outline,
              controller: controller.name,
              validator: (text) => (text?.trim().length ?? 0) < 2
                  ? 'Enter your full name'
                  : null,
            ),
            const SizedBox(height: 16),
            ShopTextField(
              label: 'Mobile number',
              hint: '10-digit mobile number',
              icon: Icons.phone_outlined,
              controller: controller.phone,
              keyboardType: TextInputType.phone,
              validator: (text) =>
                  RegExp(r'^\d{10}$').hasMatch(text?.trim() ?? '')
                      ? null
                      : 'Enter a 10-digit mobile number',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.address,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Delivery address',
                hintText: 'House, street, city, PIN',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
              validator: (text) => (text?.trim().length ?? 0) < 10
                  ? 'Enter your complete address'
                  : null,
            ),
            const SizedBox(height: 18),
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated total: ₹${controller.cart.subtotal}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'No online payment is collected. Orders remain pending until an admin verifies stock and price.',
                      style: TextStyle(color: ShopColors.muted),
                    ),
                    if (controller.error.value.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(controller.error.value,
                          style: const TextStyle(color: ShopColors.danger)),
                    ],
                    const SizedBox(height: 18),
                    ShopButton(
                      label: 'Request COD order',
                      icon: Icons.check_circle_outline,
                      isLoading: controller.isSubmitting.value,
                      onPressed: _placeOrder,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
