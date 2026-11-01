# ShopEase – Cloudinary image upload migration

**Scope:** Replace Firebase Storage product-image uploads with Cloudinary while keeping Firebase Authentication, Cloud Firestore, GetX and existing screens. Approved by DTECH for the machine test according to the project owner.

## Create Cloudinary environment and unsigned preset

1. Sign up / sign in at https://console.cloudinary.com/ and verify your email.
2. Copy the **Cloud name** shown in your Cloudinary environment/dashboard (not the API secret).
3. Go to **Settings → Upload → Upload presets → Add upload preset**. UI names can vary.
4. Choose **Unsigned** as the signing mode. Name the preset, e.g. `shopease_products_unsigned`. Copy its exact name.
5. Use a dedicated folder `shopease/products`, allow *image* assets only, and restrict formats to JPG/JPEG, PNG and WebP. Turn off client-selected public IDs / overwrite. Client-side file size is limited to <5MB; Cloudinary's upload preset does NOT provide a per-preset file-size limit.
6. Cloudinary Cloud name and unsigned preset are placed in `--dart-define`, NOT in a Dart file. **Never put Cloudinary API_SECRET or API_KEY in Flutter.** Unsigned presets are public/discoverable: they cannot enforce Firebase admin authorization. Restrict the preset and monitor usage. For a production store, use signed uploads through an authenticated backend.

## Install (after checking Git branch and working-tree state)

```powershell
cd C:\flutterDev\projects\shopease
git status
Expand-Archive -Path "$HOME\Downloads\ShopEase_Cloudinary_Migration_Kit.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force
powershell -ExecutionPolicy Bypass -File .\tools\install_cloudinary.ps1
flutter pub add http
flutter pub remove firebase_storage
dart format lib test/image_upload
powershell -ExecutionPolicy Bypass -File .\tools\check_cloudinary.ps1
```

## Run admin web with Cloudinary (PowerShell)

Replace values with your own Cloudinary Cloud name and unsigned preset. **Never use API Secret.**

```powershell
$env:CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUD_NAME'
$env:CLOUDINARY_UPLOAD_PRESET = 'YOUR_UNSIGNED_PRESET_NAME'
flutter run -d chrome -t lib/main_admin.dart --dart-define=CLOUDINARY_CLOUD_NAME=$env:CLOUDINARY_CLOUD_NAME --dart-define=CLOUDINARY_UPLOAD_PRESET=$env:CLOUDINARY_UPLOAD_PRESET
```

For release admin web build:

```powershell
flutter build web --release -t lib/main_admin.dart --dart-define=CLOUDINARY_CLOUD_NAME=$env:CLOUDINARY_CLOUD_NAME --dart-define=CLOUDINARY_UPLOAD_PRESET=$env:CLOUDINARY_UPLOAD_PRESET
```

The **customer Android** app reads existing `imageUrl` from Firestore; it doesn't upload product photos and needs no Cloudinary build flags. If you build an **admin Android app**, provide the same flags to that build.

## How it works

Admin picks photo → `ProductImageService.upload` makes `multipart/form-data` request to `https://api.cloudinary.com/v1_1/<cloud-name>/image/upload` → Cloudinary returns `secure_url` and `public_id` → existing `ProductService.saveProduct` stores only URL in `products/{productId}.imageUrl` in **Firestore**. Customer app continues using `Image.network(imageUrl)`.

* No changes to Firestore schema or security rules.
* Existing HTTP(S) image URLs remain; old Firebase Storage files are **not** migrated automatically.
* `storage.rules` is legacy/unused after this migration; leave it for historical reference or archive it separately. No Firebase Storage account or Blaze upgrade is required for this Cloudinary path.
* Unsigned Cloudinary requests **cannot securely delete images** from Flutter. If Firestore write fails after upload, remove any orphaned image from Cloudinary's Media Library. Replacing product images also does not automatically clean up the previous image.
* If upload times out, it may still complete remotely. Inspect Cloudinary Media Library before retrying repeatedly.
* Product validation is preserved (JPG/PNG/WebP, matching file signature, image <5MB).

## Manual acceptance test

- Run admin web with `--dart-define` arguments.
- Log in as admin; create product **with small selected JPG**; confirm no infinite spinner.
- Check Cloudinary Media Library contains the uploaded image.
- Check Firestore `products/{id}.imageUrl` points to HTTPS `res.cloudinary.com`.
- Run customer app (`flutter run -d chrome -t lib/main.dart`) and see product image.
- Edit same product with another image; confirm new URL displayed.
- Test no-image product, manual HTTPS URL, invalid file and upload failure.
- Test checkout/order/customer-profile features remain unchanged.
- Check Cloudinary usage quota, avoid uploading large or excessive files.

## Security / production note

The unsigned preset is **not protected by Firebase Auth**, even though the Flutter admin screen checks Firebase login. Anyone who obtains the preset can attempt uploads; this approach is approved for a short-lived demo only. For actual production, replace it with server-authorized signed upload requests and securely manage image deletion and abuse prevention.
