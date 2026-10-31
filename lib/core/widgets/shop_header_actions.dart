import 'package:flutter/material.dart';

import '../theme/shop_colors.dart';

/// One accessible, themed toolbar action.
class ShopHeaderAction extends StatelessWidget {
  const ShopHeaderAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final foreground = destructive ? ShopColors.dragonfruit : ShopColors.fig;
    final background = destructive ? ShopColors.orchid : ShopColors.paper;
    final outline = destructive ? ShopColors.dragonfruit : ShopColors.stroke;

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: IconButton(
          tooltip: label,
          icon: Icon(icon, size: 20),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            foregroundColor: foreground,
            backgroundColor: background,
            side: BorderSide(color: outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          side: BorderSide(color: outline),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

enum _AdminMenuAction { customers, orders, logout }

/// Desktop: descriptive navigation buttons. Phones/tablets: one overflow menu.
/// Keeping the group together avoids squeezing the ShopEase brand in the AppBar.
class ShopAdminHeaderActions extends StatelessWidget {
  const ShopAdminHeaderActions({
    super.key,
    required this.onCustomers,
    required this.onOrders,
    required this.onLogout,
  });

  final VoidCallback onCustomers;
  final VoidCallback onOrders;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 900) {
      return PopupMenuButton<_AdminMenuAction>(
        tooltip: 'Dashboard actions',
        icon: const Icon(Icons.more_horiz_rounded, color: ShopColors.fig),
        color: ShopColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (choice) {
          if (choice == _AdminMenuAction.customers) {
            onCustomers();
          } else if (choice == _AdminMenuAction.orders) {
            onOrders();
          } else {
            ShopLogoutAction.confirm(context, onLogout);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem<_AdminMenuAction>(
            value: _AdminMenuAction.customers,
            child: Row(children: [
              Icon(Icons.groups_2_outlined, color: ShopColors.fig),
              SizedBox(width: 12),
              Text('Customers'),
            ]),
          ),
          PopupMenuItem<_AdminMenuAction>(
            value: _AdminMenuAction.orders,
            child: Row(children: [
              Icon(Icons.receipt_long_outlined, color: ShopColors.fig),
              SizedBox(width: 12),
              Text('Orders'),
            ]),
          ),
          PopupMenuItem<_AdminMenuAction>(
            value: _AdminMenuAction.logout,
            child: Row(children: [
              Icon(Icons.logout_rounded, color: ShopColors.dragonfruit),
              SizedBox(width: 12),
              Text('Log out', style: TextStyle(color: ShopColors.dragonfruit)),
            ]),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShopHeaderAction(
          label: 'Customers',
          icon: Icons.groups_2_outlined,
          onPressed: onCustomers,
        ),
        ShopHeaderAction(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          onPressed: onOrders,
        ),
        ShopLogoutAction(onLogout: onLogout),
      ],
    );
  }
}

/// Themed two-action confirmation; Firebase is called only after approval.
class ShopLogoutAction extends StatelessWidget {
  const ShopLogoutAction({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  static Future<void> confirm(
    BuildContext context,
    Future<void> Function() onLogout,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ShopColors.paper,
        surfaceTintColor: ShopColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const CircleAvatar(
          backgroundColor: ShopColors.orchid,
          radius: 27,
          child: Icon(Icons.logout_rounded, color: ShopColors.dragonfruit),
        ),
        title: const Text(
          'Log out of ShopEase?',
          textAlign: TextAlign.center,
          style: TextStyle(color: ShopColors.fig, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'You will need to sign in again to continue.',
          textAlign: TextAlign.center,
          style: TextStyle(color: ShopColors.muted),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: ShopColors.fig),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log out'),
            style: FilledButton.styleFrom(
              backgroundColor: ShopColors.dragonfruit,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) return;
    try {
      await onLogout();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not log out. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ShopHeaderAction(
        label: 'Log out',
        icon: Icons.logout_rounded,
        destructive: true,
        onPressed: () => confirm(context, onLogout),
      );
}
