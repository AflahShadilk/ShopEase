import 'package:shopease/shared/shop_splash_screen.dart';
import 'core/theme/shop_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ShopEaseApp());
}

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase',
      theme: ShopTheme.light,
      home: const ShopSplashScreen(
        nextPage: Scaffold(
          body: Center(
            child: Text('Customer Login - Next Task'),
          ),
        ),
      ),
    );
  }
}
