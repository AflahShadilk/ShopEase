import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/shop_theme.dart';
import '../../firebase_options.dart';
import '../../services/auth_service.dart';
import '../../shared/auth_gate.dart';
import '../../shared/controllers/shop_session_controller.dart';
import '../../shared/shop_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authService = Get.put(AuthService(), permanent: true);
  Get.put(ShopSessionController(authService: authService), permanent: true);
  runApp(const ShopEaseAdminApp());
}

class ShopEaseAdminApp extends StatelessWidget {
  const ShopEaseAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase Admin',
      theme: ShopTheme.light,
      home: const ShopSplashScreen(
        isAdmin: true,
        nextPage: ShopAuthGate(isAdmin: true),
      ),
    );
  }
}
