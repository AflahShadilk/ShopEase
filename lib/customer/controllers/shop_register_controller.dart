import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../../shared/auth_gate.dart';

class ShopRegisterController extends GetxController {
  ShopRegisterController(this._auth);
  final AuthService _auth;

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final isLoading = false.obs;
  final error = ''.obs;

  Future<void> register() async {
    if (isLoading.value || !(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    error.value = '';
    try {
      await _auth.registerCustomer(
        name: name.text,
        email: email.text,
        password: password.text,
      );
      // Remove the registration route; the auth gate reacts to Firebase Auth.
      Get.offAll(() => const ShopAuthGate());
    } on FirebaseAuthException catch (e) {
      error.value = switch (e.code) {
        'email-already-in-use' => 'An account already uses this email.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Choose a stronger password.',
        'network-request-failed' => 'Check your internet connection.',
        _ => e.message ?? 'Unable to create an account.',
      };
    } on FirebaseException catch (e) {
      error.value = e.code == 'permission-denied'
          ? 'Profile creation was blocked. Check Firestore rules.'
          : 'Account created, but saving your profile failed. Contact support.';
    } catch (_) {
      error.value = 'Unable to finish registration. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
