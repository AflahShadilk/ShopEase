import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_auth_layout.dart';
import '../../../core/widgets/shop_button.dart';
import '../../../core/widgets/shop_text_field.dart';
import '../../../services/auth_service.dart';
import '../../controllers/shop_register_controller.dart';

class ShopRegisterScreen extends StatelessWidget {
  const ShopRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopRegisterController(Get.find<AuthService>()));
    return ShopAuthLayout(
      title: 'The good stuff starts here.',
      subtitle: 'Create your ShopEase account and discover something lovely.',
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShopTextField(
              label: 'Your name',
              hint: 'How should we call you?',
              icon: Icons.person_outline_rounded,
              controller: controller.name,
              validator: (value) => (value ?? '').trim().length < 2
                  ? 'Enter at least 2 characters.'
                  : null,
            ),
            const SizedBox(height: 16),
            ShopTextField(
              label: 'Email address',
              hint: 'you@example.com',
              icon: Icons.alternate_email_rounded,
              controller: controller.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = (value ?? '').trim();
                if (email.isEmpty) return 'Enter your email.';
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                  return 'Enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ShopTextField(
              label: 'Password',
              hint: 'At least 8 characters',
              icon: Icons.lock_outline_rounded,
              controller: controller.password,
              isPassword: true,
              validator: (value) => (value ?? '').length < 8
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            const SizedBox(height: 16),
            ShopTextField(
              label: 'Confirm password',
              hint: 'Type it again',
              icon: Icons.verified_user_outlined,
              controller: controller.confirmPassword,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (value) => value != controller.password.text
                  ? 'Passwords do not match.'
                  : null,
            ),
            Obx(() => controller.error.value.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      controller.error.value,
                      style: const TextStyle(color: ShopColors.danger),
                    ),
                  )),
            const SizedBox(height: 26),
            Obx(() => ShopButton(
                  label: 'Create my account',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: controller.isLoading.value,
                  onPressed:
                      controller.isLoading.value ? null : controller.register,
                )),
            const SizedBox(height: 14),
            Obx(() => TextButton(
                  onPressed:
                      controller.isLoading.value ? null : () => Get.back(),
                  child: const Text('Already a member? Sign in'),
                )),
          ],
        ),
      ),
    );
  }
}
