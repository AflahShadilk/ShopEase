# Product feature test plan

## Quick terminal checks

```powershell
flutter pub get
flutter analyze
dart format --output=none --set-exit-if-changed lib
git diff --check
powershell -ExecutionPolicy Bypass -File .\tools\check_products.ps1
```

## Manual testing checklist

1. **Auth prerequisite:** Register and sign in as a customer; no Firestore permissions error for the profile.
2. **Admin prerequisite:** Sign in through `main_admin.dart` with the separately configured admin account. A customer account must be refused.
3. **Create product:** Admin -> Add product -> enter name `Citrus Canvas Tote`, category `Accessories`, price `799`, stock `12`, description and optional HTTPS image URL -> Save.
4. **Verify Firestore:** Confirm a new `products/{autoId}` document with fields: name, description, category, price (number), stock (number), imageUrl, isActive (boolean), createdBy, createdAt, updatedAt.
5. **Customer catalog:** Sign in through `main.dart` with a customer. The created product appears without restarting the app.
6. **Details:** Tap product card. Description, price and stock appear in bottom sheet.
7. **Edit:** Change product price to `699` as admin. Customer UI should update through snapshots automatically.
8. **Hide:** Admin -> Hide. Product disappears from customer catalog but remains in admin list.
9. **Publish:** Admin -> Publish. Product returns to customer catalog.
10. **Validation:** Try blank name, negative stock, decimal price, and `http://` image URL. The form must reject them before Firestore writes.
11. **Deletion:** Create a disposable test product, delete it with confirmation, and confirm deletion in Firestore. Do NOT delete a product involved in an order.
12. **Security rules:** In Firebase Rules Playground or emulator, verify customer cannot create/update/delete a product; unauthenticated access is denied; customer cannot read hidden product documents.
13. **Small screen:** Resize browser to narrow mobile width. Confirm cards/form/actions have no overflow.
14. **Broken image:** Enter an HTTPS link to a nonexistent image; the fallback icon should display rather than crash.
15. **Logout:** Log out while viewing the catalog. Product stream should stop and login screen appear.

## Expected exceptions / troubleshooting

| Problem | Likely cause | Check |
| --- | --- | --- |
| Permission denied on admin create | Missing/wrong `users/{uid}.role`, or outdated rules | Console -> Firestore users and Rules |
| Customer list blank | No published products or wrong Firebase project | Inspect products isActive flag and firebase_options.dart |
| Missing index error | Unexpected extra query/order added | Simplify query or follow Firestore index link |
| Image placeholder | URL invalid or host denies remote images | Try optional blank image URL |
| `Get.find` fails | GetX auth patch not installed, app entry point missing controller | Ensure product patch main.dart and main_admin.dart are used |
| Flutter analyzer fails | Conflicting old files / missing dependencies | Run flutter pub get, inspect first error and check GetX patch |

**No automated Firebase integration tests are included.** Local `flutter analyze` and real app/rules tests are both required.
