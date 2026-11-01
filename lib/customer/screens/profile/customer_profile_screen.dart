import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_header_actions.dart';
import '../../../services/auth_service.dart';
import '../../../shared/controllers/shop_session_controller.dart';

/// Read-only customer profile and themed logout confirmation.
class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<ShopSessionController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Obx(() {
              final data = session.profile.value;
              final user = session.user.value;
              final rawName = (data?['name'] as String?)?.trim() ?? '';
              final displayName = rawName.isNotEmpty
                  ? rawName
                  : (user?.displayName?.trim().isNotEmpty ?? false)
                      ? user!.displayName!
                      : 'ShopEase customer';
              final email = user?.email ?? '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: ShopColors.paper,
                      border: Border.all(color: ShopColors.stroke),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: ShopColors.orchid,
                          child: Icon(Icons.person_rounded,
                              size: 36, color: ShopColors.dragonfruit),
                        ),
                        const SizedBox(height: 16),
                        Text(displayName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: ShopColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    onPressed: () => ShopLogoutAction.confirm(
                      context,
                      () => Get.find<AuthService>().logout(),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ShopColors.dragonfruit,
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: ShopColors.dragonfruit),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
