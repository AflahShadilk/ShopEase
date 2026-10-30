import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/customer/controllers/customer_cart_controller.dart';
import 'package:shopease/models/shop_product.dart';

const tote = ShopProduct(
  id: 'tote-1',
  name: 'Everyday tote',
  description: 'Canvas bag',
  category: 'Accessories',
  price: 500,
  stock: 2,
  imageUrl: '',
  isActive: true,
);

void main() {
  test('adds items, totals rupees, and clamps stock', () {
    final cart = CustomerCartController();
    expect(cart.addProduct(tote), isNull);
    expect(cart.addProduct(tote), isNull);
    expect(cart.addProduct(tote), contains('Only 2'));
    expect(cart.count, 2);
    expect(cart.subtotal, 1000);
    cart.decrease(tote.id);
    expect(cart.count, 1);
    cart.remove(tote.id);
    expect(cart.subtotal, 0);
  });

  test('rechecks live product availability and price', () {
    final cart = CustomerCartController();
    cart.addProduct(tote);
    const changed = ShopProduct(
      id: 'tote-1',
      name: 'Everyday tote',
      description: 'Canvas bag',
      category: 'Accessories',
      price: 600,
      stock: 1,
      imageUrl: '',
      isActive: true,
    );
    cart.syncProducts([changed]);
    expect(cart.subtotal, 600);
    cart.syncProducts([]);
    expect(cart.lines, isEmpty);
  });
}
