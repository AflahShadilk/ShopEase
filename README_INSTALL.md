# ShopEase | Customer Profiles + Order Tracking (GetX)

Feature base: **the completed Cart + Checkout branch** (or your updated local `main` that already contains Cart + Checkout).

No new Flutter package or Firebase product is required. The existing ShopEase colors, GetX controllers, users and orders collections, `ShopTheme.light`, and `ShopButton` remain the design/architecture foundation.

## What is added

- Admin: Customers button on Products admin app bar.
- Customer list from Firestore (`users`, filtered to `role == customer`) with name/email search.
- Customer detail page with per-customer order history and summary.
- Customer order screen: vertical visual status timeline for pending → confirmed → packed → shipped → delivered; cancelled handled explicitly.
- GetX reactive controllers with subscription cleanup.
- Responsive widget tests at 320 / 375 / 768 / 1280px and text scale 1.0 / 1.3.

## Install safely from VS Code PowerShell

```powershell
cd C:\flutterDev\projects\shopease
git status
# Ensure your local main includes previous cart + checkout commits before branching.
git switch main
git log -1 --oneline
git push origin main
# Use a new branch only if it does not already exist locally:
git switch -c feature/customer-profiles-tracking

Expand-Archive -Path "$HOME\Downloads\ShopEase_Customer_Profiles_Tracking.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force
powershell -ExecutionPolicy Bypass -File .\tools\install_profiles_tracking.ps1
dart format lib test/profiles
flutter analyze
flutter test test/profiles/
powershell -ExecutionPolicy Bypass -File .\tools\check_profiles_tracking.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check_all.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check_cart_checkout.ps1
```

Do not run the installer twice unless you must recover from an interruption. It is written to detect already inserted code and backs up edited files to `$env:TEMP\ShopEaseProfilesBackup_*`.

## Firebase data and security

The existing `users` and `orders` Firestore collections are sufficient. Existing rules should grant admin read access to users/orders, but customer accounts must only see their own profile and orders. **Do not open broad customer-list reads or order reads to all signed-in users.**

Order tracking displays the status recorded in Firestore, not a live courier location or estimated delivery date. Admin order-status changes are still made in the existing `AdminOrdersScreen`.

Cart/checkout is a **machine-test COD demonstration**. Client-side price totals are not sufficient for accepting real commercial orders; server-side authoritative validation, stock reservation/deduction, payment verification (if added), and allowed status transitions remain production work.

## Interview explanation

`CustomerDirectoryService` is responsible only for Firestore reads. `AdminCustomersController` and `AdminCustomerOrdersController` transform the streams into GetX observable UI state. Stateless widgets display data via `Obx`. `ShopOrderTimeline` is a reusable, pure UI component with no Firebase dependency, making it easy to test.

Tests check layout overflow and status sequencing, not server security. Manually verify access using different Firebase user roles.

## Commit after manual testing

```powershell
git status
git diff --check
git add -A
git diff --cached --stat
git commit -m "feat(customers): add admin profiles and order tracking"
git push -u origin feature/customer-profiles-tracking
```
