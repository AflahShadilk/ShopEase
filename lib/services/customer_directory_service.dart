import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shop_customer.dart';
import '../models/shop_order.dart';

/// The service reads existing users and orders; only admins have list access.
class CustomerDirectoryService {
  CustomerDirectoryService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<ShopCustomer>> watchCustomers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .snapshots()
        .map((snapshot) {
      final customers = snapshot.docs.map(ShopCustomer.fromDocument).toList();
      customers
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return customers;
    });
  }

  Stream<List<ShopOrder>> watchOrdersForCustomer(String customerId) {
    if (customerId.isEmpty) return Stream.value(<ShopOrder>[]);
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map(ShopOrder.fromDocument).toList();
      orders.sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
      return orders;
    });
  }
}
