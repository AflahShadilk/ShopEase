# Firebase security — Manual role/permission verification

**Prerequisite:** Rules in Firebase Console must be published and match the repository's `firestore.rules` and `storage.rules` as applicable. Use test accounts with distinct Firebase Auth UIDs; do not put passwords in logs or Git.

1. **Customer:** Read active product list. Must not edit/create/delete product docs.
2. **Customer:** Read own `users/{uid}` profile. Must not read another customer's profile or change `role` to `admin`.
3. **Customer:** Read own orders. Must not read another customer's order or update order `status`.
4. **Admin:** Read customer directory and orders, update only the allowed order status field. Cannot grant admin access via untrusted customer UI.
5. **Unauthenticated:** Cannot enumerate private `users` and `orders` collections.
6. **Storage:** Customer cannot upload into `product_images`; admin can upload a validated image under their own UID when Storage is configured; non-image and oversized uploads fail.
7. **Negative order test:** Current demo Firestore order rules validate shape/ownership but do **not** verify that `items` prices and `total` match live products. Do not characterize this as secure commercial checkout.
8. **Test release-build networking:** Android main manifest must declare INTERNET; verify Firebase login and product catalog on device, not just in debug mode.

The Firebase Console UI and the app's error messages can help confirm failures, but a successful or hidden button is not a security test. Review rules in the Firebase Emulator Suite or with targeted backend requests when possible. Never use permissive `allow read, write: if true` as a workaround.
