import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/shop_cart_line.dart';
import '../models/shop_order.dart';
import '../models/shop_product.dart';

/// Demo COD checkout. Final stock reservation and trusted price calculation
/// need a server-side function before accepting real money/orders.
class OrderService {
  OrderService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  Stream<List<ShopOrder>> watchMyOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _orders.where('customerId', isEqualTo: user.uid).snapshots().map(
      (snapshot) {
        final orders = snapshot.docs.map(ShopOrder.fromDocument).toList();
        orders.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));
        return orders;
      },
    );
  }

  Stream<List<ShopOrder>> watchAdminOrders() {
    return _orders.snapshots().map((snapshot) {
      final orders = snapshot.docs.map(ShopOrder.fromDocument).toList();
      orders.sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
      return orders;
    });
  }

  Future<String> placeCodOrder({
    required List<ShopCartLine> lines,
    required String name,
    required String phone,
    required String address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    if (lines.isEmpty || lines.length > 10) {
      throw StateError('Please add 1 to 10 different products.');
    }
    if (name.trim().length < 2 || address.trim().length < 10) {
      throw StateError('Please complete your delivery information.');
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone.trim())) {
      throw StateError('Enter a 10-digit mobile number.');
    }

    final ref = _orders.doc();
    await _db.runTransaction((transaction) async {
      final verified = <Map<String, dynamic>>[];
      var total = 0;
      for (final line in lines) {
        if (line.quantity < 1 || line.quantity > 20) {
          throw StateError('Invalid product quantity.');
        }
        final snapshot = await transaction.get(
          _db.collection('products').doc(line.product.id),
        );
        if (!snapshot.exists) throw StateError('A product was removed.');
        final product = ShopProduct.fromDocument(snapshot);
        if (!product.isActive || product.stock < line.quantity) {
          throw StateError('${product.name} is unavailable at this quantity.');
        }
        total += product.price * line.quantity;
        verified.add({
          'productId': product.id,
          'name': product.name,
          'quantity': line.quantity,
          'price': product.price,
        });
      }
      if (total <= 0 || total > 10000000) {
        throw StateError('Order total is outside the supported range.');
      }
      transaction.set(ref, {
        'customerId': user.uid,
        'customerName': name.trim(),
        'phone': phone.trim(),
        'shippingAddress': address.trim(),
        'items': verified,
        'subtotal': total,
        'total': total,
        'paymentMethod': 'cash_on_delivery',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    return ref.id;
  }

  Future<void> updateStatus(String orderId, String status) {
    const states = [
      'pending',
      'confirmed',
      'packed',
      'shipped',
      'delivered',
      'cancelled'
    ];
    if (!states.contains(status)) throw ArgumentError.value(status, 'status');
    return _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
