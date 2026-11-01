import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/shop_colors.dart';
import '../../core/widgets/shop_auth_layout.dart';
import '../../core/widgets/shop_button.dart';
import '../../core/widgets/shop_text_field.dart';
import '../../customer/screens/auth/shop_register_screen.dart';
import '../../services/auth_service.dart';
import '../controllers/shop_login_controller.dart';

class ShopLoginScreen extends StatelessWidget {
  const ShopLoginScreen({
    super.key,
    this.isAdmin = false,
  });

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ShopLoginController(
        Get.find<AuthService>(),
        isAdmin: isAdmin,
      ),
      tag: isAdmin ? 'admin-login' : 'customer-login',
    );

    return ShopAuthLayout(
      isAdmin: isAdmin,
      title:
          isAdmin ? 'Welcome to the control room.' : 'Good to see you again.',
      subtitle: isAdmin
          ? 'Sign in with your approved ShopEase administrator account.'
          : 'Your next great find is just one sign-in away.',
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // EMAIL FIELD
            ShopTextField(
              label: 'Email address',
              hint: 'you@example.com',
              icon: Icons.alternate_email_rounded,
              controller: controller.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = (value ?? '').trim();

                if (email.isEmpty) {
                  return 'Enter your email.';
                }

                if (!RegExp(
                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                ).hasMatch(email)) {
                  return 'Enter a valid email.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // PASSWORD FIELD
            ShopTextField(
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              controller: controller.password,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Enter your password.';
                }
                return null;
              },
            ),

            // DEMO LOGIN BUTTONS
            if (controller.canFillReviewerCredentials) ...[
              const SizedBox(height: 14),

              // ADMIN WEB: Keep original button
              if (isAdmin)
                OutlinedButton.icon(
                  onPressed: controller.fillReviewerCredentials,
                  icon: const Icon(Icons.badge_outlined),
                  label: const Text('Fill demo login'),
                )

              // CUSTOMER APP: Autofill + Autofill & Login
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final autofillButton = OutlinedButton.icon(
                      onPressed: controller.fillReviewerCredentials,
                      icon: const Icon(
                        Icons.auto_fix_high_rounded,
                      ),
                      label: const Text('Autofill'),
                    );

                    final autofillAndLoginButton = ElevatedButton.icon(
                      onPressed: () {
                        // Fill customer demo credentials.
                        controller.fillReviewerCredentials();

                        // Authenticate using Firebase.
                        controller.signIn();
                      },
                      icon: const Icon(
                        Icons.login_rounded,
                      ),
                      label: const Text('Autofill & login'),
                    );

                    // Small mobile screens:
                    // Stack the buttons vertically.
                    if (constraints.maxWidth < 440) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          autofillButton,
                          const SizedBox(height: 10),
                          autofillAndLoginButton,
                        ],
                      );
                    }

                    // Wider layouts:
                    // Display the buttons side by side.
                    return Row(
                      children: [
                        Expanded(
                          child: autofillButton,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: autofillAndLoginButton,
                        ),
                      ],
                    );
                  },
                ),
            ],

            // AUTHENTICATION ERROR MESSAGE
            Obx(
              () => controller.error.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: Text(
                        controller.error.value,
                        style: const TextStyle(
                          color: ShopColors.danger,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 26),

            // MAIN LOGIN BUTTON
            Obx(
              () => ShopButton(
                label: isAdmin ? 'Enter dashboard' : 'Sign in',
                icon: Icons.arrow_forward_rounded,
                isLoading: controller.isLoading.value,
                onPressed:
                    controller.isLoading.value ? null : controller.signIn,
              ),
            ),

            // CUSTOMER REGISTRATION
            if (!isAdmin) ...[
              const SizedBox(height: 22),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('New around here? '),
                    Obx(
                      () => TextButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => Get.to(
                                  () => const ShopRegisterScreen(),
                                ),
                        child: const Text(
                          'Create an account',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]

            // ADMIN INFORMATION
            else ...[
              const SizedBox(height: 20),
              const Text(
                'Admin accounts are assigned by the ShopEase team. '
                'Public registration is disabled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ShopColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
