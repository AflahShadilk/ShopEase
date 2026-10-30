import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';

class ShopLoginController extends GetxController {
  ShopLoginController(this._auth);
  final AuthService _auth;

  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final isLoading = false.obs;
  final error = ''.obs;

  Future<void> signIn() async {
    if (isLoading.value || !(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    error.value = '';
    try {
      await _auth.login(email: email.text, password: password.text);
      // The reactive ShopAuthGate handles the signed-in screen.
    } on FirebaseAuthException catch (e) {
      error.value = switch (e.code) {
        'invalid-email' => 'Check your email address.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Email or password is incorrect.',
        'too-many-requests' => 'Too many attempts. Please try later.',
        'network-request-failed' => 'Check your internet connection.',
        _ => e.message ?? 'Unable to sign in right now.',
      };
    } catch (_) {
      error.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
