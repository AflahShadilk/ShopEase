import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/customer/widgets/customer_product_tile.dart';
import 'package:shopease/models/shop_product.dart';

const _product = ShopProduct(
  id: 'sample',
  name: 'Compact canvas tote with a long product name',
  description: 'Demo',
  category: 'Accessories',
  price: 333,
  stock: 3,
  imageUrl: '',
  isActive: true,
);

void main() {
  for (final width in [320.0, 375.0, 600.0]) {
    testWidgets('Compact customer grid card at ${width.toInt()}px',
        (tester) async {
      final cardWidth = (width - 40 - 12) / 2;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: cardWidth,
              height: 244,
              child: CustomerProductTile(product: _product, onTap: () {}),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('₹333'), findsOneWidget);
    });

    testWidgets('Customer list card at ${width.toInt()}px', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width - 40,
              child: CustomerProductTile(
                  product: _product, onTap: () {}, isGrid: false),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('₹333'), findsOneWidget);
    });
  }
}
