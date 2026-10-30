import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/controllers/shop_splash_controller.dart';
import '../core/theme/shop_colors.dart';
import '../core/widgets/shop_brand.dart';

/// Reuses one branded splash with different customer/admin destinations.
class ShopSplashScreen extends StatelessWidget {
  const ShopSplashScreen({
    super.key,
    required this.nextPage,
    this.isAdmin = false,
  });

  final Widget nextPage;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopSplashController(destination: nextPage));
    return Scaffold(
      backgroundColor: ShopColors.fig,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 28,
              left: 26,
              child: Text(
                'S / E    •    01',
                style: TextStyle(
                  color: ShopColors.yuzu,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            Center(
              child: Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 650),
                  opacity: controller.visible.value ? 1 : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    scale: controller.visible.value ? 1 : .88,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ShopMark(size: 94),
                        const SizedBox(height: 25),
                        Text(
                          'shop ease',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 42,
                                letterSpacing: -2.2,
                              ),
                        ),
                        const SizedBox(height: 11),
                        Text(
                          isAdmin
                              ? 'THE CONTROL ROOM'
                              : 'EVERY CART. A LITTLE SPARK.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ShopColors.yuzu,
                            fontSize: 11,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ShopColors.dragonfruit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
