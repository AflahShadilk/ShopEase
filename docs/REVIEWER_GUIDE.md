# ShopEase — Machine Test Reviewer Guide

## Overview

ShopEase is a Flutter/Firebase e-commerce demonstration with two app entry points in one repository:

| App | Entrypoint | Target | Primary features |
| --- | --- | --- | --- |
| Customer | `lib/main.dart` | Android | Firebase sign-in, catalog, cart, COD checkout, order history and tracking |
| Admin | `lib/main_admin.dart` | Web (Chrome) | Admin products, images, orders/status, customer directory/history |

**State management:** GetX controllers with observable state (`.obs`, `Obx`).  
**UI:** Shared ShopColors / ShopTheme, Dragonfruit × Yuzu design, reusable widgets.  
**Data:** Firebase Authentication, Cloud Firestore, optionally Cloud Storage for images.  
**Offline support:** Not claimed; Firebase client SDK caching may occur but is not an offline-first order implementation.

## Local setup

1. Install Flutter, Android SDK, Chrome and Java compatible with this Flutter project.
2. Run `flutter pub get` from repository root.
3. Configure the existing ShopEase Firebase app if using a different Firebase project (`flutterfire configure`).
4. Ensure Firebase Authentication Email/Password is enabled and Firestore rules are published.
5. Customer: `flutter run -d <android_device_id> -t lib/main.dart`.
6. Admin: `flutter run -d chrome -t lib/main_admin.dart`.
7. To generate submission artifacts: `powershell -ExecutionPolicy Bypass -File .\tools\build_submission.ps1` on Windows.

## Firebase collections

- `users/{uid}` — customer/admin roles and profile fields.
- `products/{id}` — product name, description, category, price (integer rupees), stock, active status, image URL.
- `orders/{id}` — COD order request with customer id, line items, shipping info and admin-controlled status.
- `product_images/{adminUid}/...` — optional Firebase Storage image objects (not a Firestore collection).

## Interview walkthrough

1. **Why one Flutter repository?** Shared models/widgets/theme and separate Flutter entry points reduce duplicated code while producing distinct customer and admin targets.
2. **Why GetX?** Domain/UI state is observable; widgets update via `Obx` while services own backend calls.
3. **What enforces roles?** Firestore and Storage security rules, not simply role-based routing in Flutter.
4. **Why Firestore streams?** Catalog, order states and customer directory can respond to updates without manual polling.
5. **How is checkout handled?** Demo COD request with client-side re-checks. Real payments/stock reservations require server-authoritative backend logic.
6. **Why separate APK and web builds?** Customer mobile experience and administrative browser experience each need their own application entry point.

## Known limitations

The project is a **machine-test demonstration**, not production e-commerce. Admin verifies stock before confirming COD orders. Real orders need backend validation for prices, line items, totals, inventory reservation, and idempotent confirmation. Product photos from Firebase Storage require bucket/billing/rules configuration; the form also supports HTTPS URLs. Android currently uses the project's debug signing configuration even for a release-mode build. For Play Store distribution, configure a proper release keystore, correct app identity and upload process.
