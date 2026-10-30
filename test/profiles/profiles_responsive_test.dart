import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/widgets/shop_customer_card.dart';
import 'package:shopease/core/widgets/shop_order_timeline.dart';
import 'package:shopease/models/shop_customer.dart';

const customer = ShopCustomer(
  id: 'customer-1',
  name: 'A very long customer name to test narrow screens',
  email: 'a.very.long.customer.email.address@example.com',
);

Future<void> check(
  WidgetTester tester,
  Widget child,
  double width,
  double scale,
) async {
  await tester.binding.setSurfaceSize(Size(width, 800));
  addTearDown(() async => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    builder: (context, widget) => MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: widget!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    ),
  ));
  await tester.pump();
  expect(tester.takeException(), isNull,
      reason: 'Layout overflow at $width px, text scale $scale');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final width in <double>[320, 375, 768, 1280]) {
    for (final scale in <double>[1, 1.3]) {
      testWidgets('Customer card $width px text $scale', (tester) async {
        await check(
          tester,
          const ShopCustomerCard(customer: customer),
          width,
          scale,
        );
        expect(find.byType(ShopCustomerCard), findsOneWidget);
      });
      testWidgets('Tracking timeline $width px text $scale', (tester) async {
        await check(
          tester,
          const ShopOrderTimeline(status: 'shipped'),
          width,
          scale,
        );
        expect(find.byType(ShopOrderTimeline), findsOneWidget);
      });
    }
  }
}
