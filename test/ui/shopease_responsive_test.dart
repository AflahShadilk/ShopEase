import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/theme/shop_colors.dart';
import 'package:shopease/core/widgets/shop_auth_layout.dart';
import 'package:shopease/core/widgets/shop_brand.dart';
import 'package:shopease/core/widgets/shop_button.dart';
import 'package:shopease/core/widgets/shop_editor_layout.dart';
import 'package:shopease/core/widgets/shop_product_card.dart';
import 'package:shopease/core/widgets/shop_text_field.dart';
import 'package:shopease/models/shop_product.dart';

const _sampleProduct = ShopProduct(
  id: 'ui-test-product',
  name: 'Everyday Canvas Tote With Extra Long Product Name',
  description: 'A durable and colorful everyday tote.',
  category: 'Accessories and Everyday Essentials',
  price: 1499,
  stock: 12,
  imageUrl: '',
  isActive: true,
);

Widget _app(Widget screen, double scale) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ShopColors.cream,
      colorScheme: ColorScheme.fromSeed(seedColor: ShopColors.dragonfruit),
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
      ),
      child: child!,
    ),
    home: screen,
  );
}

Future<void> _atSize(
  WidgetTester tester, {
  required Size size,
  required Widget screen,
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_app(screen, textScale));
  await tester.pump();
  final error = tester.takeException();
  expect(error, isNull,
      reason: 'Flutter reported a layout/build error at '
          '${size.width}x${size.height}, text scale $textScale.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final width in <double>[320, 375, 600, 1024]) {
    for (final scale in <double>[1, 1.3]) {
      testWidgets('Auth form: ${width.toInt()}px, text $scale', (tester) async {
        await _atSize(
          tester,
          size: Size(width, 800),
          textScale: scale,
          screen: ShopAuthLayout(
            title: 'Welcome to ShopEase',
            subtitle: 'A fresh way to find your next favorite thing.',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShopTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const ShopTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outlined,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                ShopButton(label: 'Sign in', onPressed: () {}),
              ],
            ),
          ),
        );
        expect(find.byType(ShopTextField), findsNWidgets(2));
        expect(find.byType(ShopButton), findsOneWidget);
        expect(find.byType(ShopBrand), findsWidgets);
      });

      testWidgets('Admin editor: ${width.toInt()}px, text $scale',
          (tester) async {
        await _atSize(
          tester,
          size: Size(width, 800),
          textScale: scale,
          screen: ShopEditorLayout(
            title: 'Add a product',
            subtitle: 'Give this product a clear name and price.',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShopTextField(
                  label: 'Product name',
                  hint: 'Canvas tote',
                  icon: Icons.shopping_bag_outlined,
                ),
                const SizedBox(height: 16),
                ShopButton(label: 'Save product', onPressed: () {}),
              ],
            ),
          ),
        );
        expect(find.byType(ShopTextField), findsOneWidget);
        expect(find.byType(ShopButton), findsOneWidget);
      });
    }
  }

  for (final width in <double>[320, 440, 768, 1280]) {
    for (final scale in <double>[1, 1.3]) {
      testWidgets('Product card: ${width.toInt()}px, text $scale',
          (tester) async {
        final contentWidth = (width - 40).clamp(0.0, 1180.0);
        final columns = contentWidth >= 1020
            ? 4
            : contentWidth >= 700
                ? 3
                : contentWidth >= 440
                    ? 2
                    : 1;
        final cardWidth = (contentWidth - (columns - 1) * 16) / columns;
        await _atSize(
          tester,
          size: Size(width, 800),
          textScale: scale,
          screen: Scaffold(
            body: Center(
              child: SizedBox(
                width: cardWidth,
                height: 335,
                child: const ShopProductCard(product: _sampleProduct),
              ),
            ),
          ),
        );
        expect(find.byType(ShopProductCard), findsOneWidget);
      });
    }
  }
}
