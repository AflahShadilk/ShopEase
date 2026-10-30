import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/shop_theme.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'customer/controllers/customer_cart_controller.dart';
import 'customer/controllers/customer_orders_controller.dart';
import 'customer/controllers/customer_catalog_controller.dart';
import 'shared/auth_gate.dart';
import 'shared/controllers/shop_session_controller.dart';
import 'shared/shop_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authService = Get.put(AuthService(), permanent: true);
  final session = Get.put(
    ShopSessionController(authService: authService),
    permanent: true,
  );
  final productService = Get.put(ProductService(), permanent: true);
  Get.put(
    CustomerCatalogController(service: productService, session: session),
    permanent: true,
  );
  final orderService = Get.put(OrderService(), permanent: true);
  Get.put(CustomerCartController(session: session), permanent: true);
  Get.put(CustomerOrdersController(service: orderService, session: session),
      permanent: true);
  runApp(const ShopEaseApp());
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase',
      theme: ShopTheme.light,
      home: const ShopSplashScreen(nextPage: ShopAuthGate()),
    );
  }
}
