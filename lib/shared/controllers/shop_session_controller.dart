import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';

/// Converts Firebase auth/profile streams into reactive GetX application state.
/// The Firestore rules still provide actual authorization.
class ShopSessionController extends GetxController {
  ShopSessionController({required this.authService, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final AuthService authService;
  final FirebaseFirestore _firestore;

  final user = Rxn<User>();
  final profile = Rxn<Map<String, dynamic>>();
  final isChecking = true.obs;
  final error = ''.obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = authService.authStateChanges.listen(
      _handleAuthChanged,
      onError: (Object _) {
        error.value = 'Unable to check your login session.';
        isChecking.value = false;
      },
    );
  }

  void _handleAuthChanged(User? nextUser) {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    user.value = nextUser;
    profile.value = null;
    error.value = '';
    isChecking.value = nextUser != null;

    if (nextUser == null) return;

    _profileSubscription = _firestore
        .collection('users')
        .doc(nextUser.uid)
        .snapshots()
        .listen(
      (snapshot) {
        profile.value = snapshot.data();
        error.value = '';
        isChecking.value = false;
      },
      onError: (Object _) {
        error.value = 'Could not load your profile. Check Firestore rules.';
        isChecking.value = false;
      },
    );
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
}
