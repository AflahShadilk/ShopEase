import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controls the brief brand animation and its one-time navigation.
class ShopSplashController extends GetxController {
  ShopSplashController({required this.destination});

  final Widget destination;
  final visible = false.obs;

  @override
  void onReady() {
    super.onReady();
    visible.value = true;
    _completeSplash();
  }

  Future<void> _completeSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (isClosed) return;
    Get.off(
      () => destination,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }
}
