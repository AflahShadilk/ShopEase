# ShopEase — Product Photo Upload (GetX / Flutter + Firebase Storage)

This feature was developed against GitHub `main` commit `9999a425ed28641a6946958243c8763e4d87b29d`. It **does not** replace cart, checkout, order tracking, product catalog or admin customer screens.

## What it adds

- Admin product form: select JPG / PNG / WebP, show preview, remove selection, save via Cloud Storage.
- 5 MB client limit, file-extension and magic-signature validation, content-type metadata; file upload names are unique for an admin.
- Uploaded download URL stored in existing Firestore `products/{id}.imageUrl`. Customer catalog already displays it; no product schema change.
- On Firestore failure, attempt to remove freshly uploaded file; existing images are not automatically deleted when replaced/deleting products.
- Keeps the **Image URL (optional alternative)** so the machine-test demo can continue without Storage billing. Selected device file has priority on save.
- Existing `ShopColors`, `ShopTheme.light`, `ShopEditorLayout`, `ShopButton`, GetX controller and service separation unchanged.

## Install — VS Code PowerShell (Windows)

1. Confirm your existing ShopEase features have been merged and pushed to `main`:

```powershell
cd C:\flutterDev\projects\shopease
git status
git fetch origin
git switch main
git pull --ff-only origin main
git switch -c feature/product-image-upload --track origin/feature/product-image-upload
```

Use `git switch feature/product-image-upload` if the branch already exists locally. Do **not** run `git switch -c` twice. Ensure the working tree is clean before installing.

2. Download `ShopEase_Product_Image_Upload.zip` to Downloads, then:

```powershell
Expand-Archive -Path "$HOME\Downloads\ShopEase_Product_Image_Upload.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force
powershell -ExecutionPolicy Bypass -File .\tools\install_product_images.ps1
flutter pub add image_picker
dart format lib test/image_upload
flutter analyze
flutter test test/image_upload/
powershell -ExecutionPolicy Bypass -File .\tools\check_product_images.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check_all.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check_cart_checkout.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check_profiles_tracking.ps1
```

The installer only copies in the updated **product form and controller**, after backing up originals to `%TEMP%\ShopEaseImageBackup_*`. It refuses to overwrite uncommitted edits. The ZIP contains two temporary `patches` files, which the installer removes after use. Do not run the installer twice.

## Firebase Storage setup

Cloud Storage now requires the **Blaze (pay-as-you-go)** plan even for default buckets. No-cost usage allowances may apply, but billing must be enabled. If you decide not to enable billing, leave the Photo picker unused and use HTTPS image URLs instead. Do not claim Storage upload is operational without a successful real test.

- Firebase Console → Build → Storage → Set up/confirm default bucket.
- Firebase Console → Storage → Rules → replace **Storage rules only** with `storage.rules`; review, then Publish. **This is not the Firestore `firestore.rules` file.**
- Rules permit authenticated reads, **admin-role-only uploads**, restrict paths to the admin's UID, and enforce JPEG/PNG/WebP MIME and maximum 5 MB. They use `firestore.get()`/`firestore.exists()` to check users/{uid}.role; Firebase may prompt to enable Storage-to-Firestore rules integration/IAM permissions.
- Uploaded `getDownloadURL()` URLs contain a token; possession of this URL allows reading the image even without authentication. These are PUBLIC PRODUCT IMAGES, never private information.
- Testing: admin login → Add product → Choose image → Save → verify `product_images/{uid}/...` object in Storage, saved Firestore `imageUrl`, customer card image. Check logged-out/customer cannot upload by Security Rules test/emulator or direct test account.
- Admin replacing an image does NOT automatically delete the old image (to avoid deleting shared references). Clean up unused media separately later.

## Limitations

This is a demo/product-management feature; image validation on client and metadata checking in Rules cannot guarantee files are safe. Production requires server-side image scanning/transcoding, App Check, quota controls, storage cleanup, moderation, and billing alerts. No Cloud Storage or emulator tests have been run in this delivery environment, so test the rules before deployment.

## Interview explanation

- `image_picker` returns an `XFile` on Chrome and Android; `readAsBytes()` gives a `Uint8List` for `FirebaseStorage.ref().putData()`.
- `ProductImageService` contains image selection/uploading logic; `ProductFormController` manages GetX state (`Rxn`, `RxBool`); `ShopImagePickerField` is a reusable stateless widget for mobile+web.
- Firestore stores only the returned HTTPS download URL, not the image bytes.
- Cloud Storage Rules enforce access on the backend, not `Obx` or UI controls.

## After real testing

```powershell
git status
git diff --check
git add -A
git diff --cached --stat
git commit -m "feat(images): add admin product photo upload via Firebase Storage"
git push -u origin feature/product-image-upload
```
