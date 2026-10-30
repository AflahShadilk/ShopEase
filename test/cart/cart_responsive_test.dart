import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/widgets/shop_cart_item_tile.dart';
import 'package:shopease/core/widgets/shop_checkout_layout.dart';
import 'package:shopease/models/shop_cart_line.dart';
import 'package:shopease/models/shop_product.dart';

const product = ShopProduct(
  id: 'item-1',
  name: 'Extra long everyday tote product name for testing',
  description: 'A little spark',
  category: 'Accessories',
  price: 1999,
  stock: 4,
  imageUrl: '',
  isActive: true,
);

Future<void> check(
    WidgetTester tester, Widget screen, double width, double scale) async {
  await tester.binding.setSurfaceSize(Size(width, 800));
  addTearDown(() async => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: screen,
  ));
  await tester.pump();
  expect(tester.takeException(), isNull,
      reason: 'Overflow at ${width}px with text scale $scale');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final width in [320.0, 375.0, 768.0, 1280.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('Cart item at ${width}px and text $scale', (tester) async {
        await check(
            tester,
            Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ShopCartItemTile(
                    line: const ShopCartLine(product: product, quantity: 2),
                    onIncrease: () {},
                    onDecrease: () {},
                    onRemove: () {},
                  ),
                ),
              ),
            ),
            width,
            scale);
        expect(find.byType(ShopCartItemTile), findsOneWidget);
      });
      testWidgets('Checkout layout at ${width}px and text $scale',
          (tester) async {
        await check(
            tester,
            const ShopCheckoutLayout(
              title: 'Checkout, simply.',
              subtitle: 'Fill out your delivery information.',
              child: Column(
                children: [
                  TextField(
                      decoration: InputDecoration(labelText: 'Full name')),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Phone')),
                ],
              ),
            ),
            width,
            scale);
        expect(find.byType(TextField), findsNWidgets(2));
      });
    }
  }
}
