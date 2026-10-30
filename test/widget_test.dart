import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/widgets/shop_product_card.dart';
import 'package:shopease/models/shop_product.dart';

void main() {
  testWidgets('ShopEase product card displays product and price', (
    tester,
  ) async {
    const product = ShopProduct(
      id: 'release-smoke-test',
      name: 'Canvas Tote',
      description: 'A practical canvas tote',
      category: 'Accessories',
      price: 799,
      stock: 5,
      imageUrl: '',
      isActive: true,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 335,
              child: ShopProductCard(product: product),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Canvas Tote'), findsOneWidget);
    expect(find.text('₹799'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
