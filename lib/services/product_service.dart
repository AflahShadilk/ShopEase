import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/shop_product.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  Stream<List<ShopProduct>> watchCustomerProducts() {
    return _products.where('isActive', isEqualTo: true).snapshots().map(
      (snapshot) {
        final products = snapshot.docs.map(ShopProduct.fromDocument).toList();
        products.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return products;
      },
    );
  }

  Stream<List<ShopProduct>> watchAdminProducts() {
    return _products.snapshots().map((snapshot) {
      final products = snapshot.docs.map(ShopProduct.fromDocument).toList();
      products
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return products;
    });
  }

  Future<void> saveProduct({
    ShopProduct? existing,
    required String name,
    required String description,
    required String category,
    required int price,
    required int stock,
    required String imageUrl,
    required bool isActive,
  }) async {
    if (existing == null) {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw StateError('Admin session expired. Log in again.');
      await _products.add({
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _products.doc(existing.id).update({
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> setActive(ShopProduct product, bool active) =>
      _products.doc(product.id).update({
        'isActive': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteProduct(ShopProduct product) =>
      _products.doc(product.id).delete();
}
