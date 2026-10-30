import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/order_service.dart';
import 'customer_cart_controller.dart';

class ShopCheckoutController extends GetxController {
  ShopCheckoutController({required this.cart, required this.orders});

  final CustomerCartController cart;
  final OrderService orders;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final isSubmitting = false.obs;
  final error = ''.obs;

  Future<bool> submit() async {
    if (isSubmitting.value || !(formKey.currentState?.validate() ?? false)) {
      return false;
    }
    if (cart.lines.isEmpty) {
      error.value = 'Your bag is empty.';
      return false;
    }
    isSubmitting.value = true;
    error.value = '';
    try {
      await orders.placeCodOrder(
        lines: cart.lines,
        name: name.text,
        phone: phone.text,
        address: address.text,
      );
      cart.clear();
      return true;
    } catch (e) {
      error.value = e is StateError
          ? e.message
          : 'Order could not be placed. Check your connection and Firestore rules.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    super.onClose();
  }
}
