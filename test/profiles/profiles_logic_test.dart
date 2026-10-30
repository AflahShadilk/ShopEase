import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/widgets/shop_order_timeline.dart';
import 'package:shopease/models/shop_customer.dart';

void main() {
  test('customer map uses the Firestore document id', () {
    final customer = ShopCustomer.fromMap('customer-123', {
      'name': 'Amina',
      'email': 'amina@example.com',
      'role': 'customer',
    });
    expect(customer.id, 'customer-123');
    expect(customer.name, 'Amina');
    expect(customer.email, 'amina@example.com');
  });

  test('tracking status progression is ordered', () {
    expect(ShopOrderTimeline.progressFor('pending'), 0);
    expect(ShopOrderTimeline.progressFor('confirmed'), 1);
    expect(ShopOrderTimeline.progressFor('packed'), 2);
    expect(ShopOrderTimeline.progressFor('shipped'), 3);
    expect(ShopOrderTimeline.progressFor('delivered'), 4);
    expect(ShopOrderTimeline.progressFor('cancelled'), -1);
  });
}
