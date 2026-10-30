# ShopEase — Final Submission Checklist

Machine-test deadline: **2 November 2026** (confirm exact hour in your original assignment email).

## Core features to show

- [ ] Customer Android app: sign up/sign in, browsing active products, product details, cart, quantity limits, checkout with validated name/phone/address, COD order request, order history and tracking.
- [ ] Admin Flutter web: admin-role login, create/edit/hide/delete products, image URL and optional Storage upload, orders and status updates, customer profiles and order history.
- [ ] Firestore and Storage security rules are deployed to their **respective** Firebase products; do not swap the two files.
- [ ] Customer role cannot access admin pages or write product documents; admin access uses Firestore role checks, not just hidden UI.
- [ ] Customer cannot see another customer's private profile or orders.
- [ ] Firebase Storage: test an admin upload only if bucket enabled and billing/rules set; if not, disclose that HTTPS URL fallback was demonstrated.
- [ ] Test blank, invalid and very long fields; test empty catalog/cart, out-of-stock products, cancelled orders.
- [ ] Test 320 / 375 / 768 / 1280px and text scaling 100% / 130%; no obscured button, clipped text, or RenderFlex overflow.

## Build evidence

- [ ] `dart format lib test` clean.
- [ ] `flutter analyze` reports no issues.
- [ ] `flutter test` passes *all* tests, including `test/widget_test.dart`.
- [ ] `tools/check_release_readiness.ps1` passes.
- [ ] APK built with `flutter build apk --release -t lib/main.dart`.
- [ ] APK installed and launched on a physical Android device; Firebase login, Firestore catalog and order workflow demonstrated.
- [ ] Admin built using `flutter build web --release -t lib/main_admin.dart`.
- [ ] Admin web tested in a real Chrome browser or deployed to the **correct** Firebase Hosting site.
- [ ] Build report with SHA-256 checksums produced by `tools/build_submission.ps1`.
- [ ] Screenshots or a short screen recording demonstrating customer and admin workflows captured manually.

## Handover

- [ ] New branch pushed and merged only after live testing.
- [ ] Source GitHub link, APK file, admin web link or ZIP, run instructions, Firebase architecture, and test evidence included.
- [ ] No private passwords, keystores, tokens, account cookies or billing details included.
- [ ] Clearly disclose remaining demo limitations: debug-signed APK, COD only, no trusted backend stock/price enforcement, optional Storage billing.
- [ ] Reproduce the project on fresh install if time permits: `flutter pub get` and launch both entry points.

**Do not claim automated UI tests prove Firebase security.** Use separate admin and customer accounts and try forbidden actions on the backend, not only through hidden buttons.
