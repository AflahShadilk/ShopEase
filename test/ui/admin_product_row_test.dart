import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/admin/widgets/admin_product_row.dart';
import 'package:shopease/models/shop_product.dart';

const sample = ShopProduct(
  id: 'thumb-test',
  name: 'Canvas Bag With Long Name To Check Text Wrapping',
  description: 'Demo',
  category: 'Accessories',
  price: 899,
  stock: 3,
  imageUrl: '',
  isActive: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final width in <double>[320, 375, 768, 1280]) {
    testWidgets('Admin product image row fits ${width.toInt()}px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AdminProductRow(
                product: sample,
                isBusy: false,
                onEdit: () {},
                onVisibility: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.textContaining('Stock: 3'), findsOneWidget);
      expect(find.byTooltip('Edit'), findsOneWidget);
    });
  }
}
