# ShopEase reviewer UI update

Updates the existing Cloudinary-migrated ShopEase app without touching the Cloudinary upload service, Firebase settings, Firestore rules or Android build files.

Changes:
1. Left product thumbnail in admin product list, responsive at mobile/tablet/desktop sizes. Empty or broken image URL shows a placeholder icon.
2. Removes only the S/E 01 badge from the shared splash screen.
3. Adds an optional **Fill demo login** button to both admin and customer login screens. It only appears when review mode is enabled AND credentials for that role are supplied via Flutter compile-time configuration. It does not sign in automatically.

## Install

Run from PowerShell in `C:\flutterDev\projects\shopease` (stay on your existing `feature/cloudinary-migration` branch):

```powershell
Expand-Archive -Path "$HOME\Downloads\ShopEase_Reviewer_UI_Kit.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force
powershell -ExecutionPolicy Bypass -File .\tools\install_reviewer_ui.ps1
dart format lib test
flutter analyze
flutter test
```

Review `git status` and `git diff` before committing. The installer backs up replaced files in TEMP. Do not reset/discard your earlier `android/app/build.gradle` build fixes.

## Configure admin review build

You already have `config/cloudinary.json` containing CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET. Copy that file and edit ONLY the local copy for the reviewer build:

```powershell
Copy-Item config/cloudinary.json config/reviewer_admin.json
```

Then in `config/reviewer_admin.json`, add these three fields inside the existing JSON object, with a comma after the previous property:

```json
"SHOP_REVIEW_MODE": "true",
"SHOP_REVIEW_ADMIN_EMAIL": "YOUR_DEDICATED_REVIEW_ADMIN_EMAIL",
"SHOP_REVIEW_ADMIN_PASSWORD": "YOUR_DEDICATED_REVIEW_ADMIN_PASSWORD"
```

Or use `review_patch_assets/config/reviewer_admin.example.json` to see the full valid JSON structure.

Run admin web:

```powershell
flutter run -d chrome -t lib/main_admin.dart --dart-define-from-file=config/reviewer_admin.json
```

This includes Cloudinary settings and reviewer login settings in the same build.

## Configure customer review build

Copy `review_patch_assets/config/reviewer_customer.example.json` to `config/reviewer_customer.json`, add a dedicated CUSTOMER account's credentials (role customer; register normally through the customer app), then run:

```powershell
flutter run -d chrome -t lib/main.dart --dart-define-from-file=config/reviewer_customer.json
```

For an Android reviewer APK (not Play Store production signing):

```powershell
flutter build apk --release -t lib/main.dart --dart-define-from-file=config/reviewer_customer.json
```

For an admin web build:

```powershell
flutter build web --release -t lib/main_admin.dart --dart-define-from-file=config/reviewer_admin.json
```

## SECURITY: IMPORTANT

Even when the JSON files are gitignored, Flutter `--dart-define` inserts their values into the compiled app. Anyone who downloads a reviewer web build/APK can potentially recover the demo credentials. An administrator demo password effectively gives FULL ADMIN ACCESS to your Firebase project. A button that fills the password cannot securely hide that password. Use separate, temporary reviewer accounts on a demo Firebase project (ideally with disposable/test-only data), never a personal/production admin account. Disable this feature in regular builds by omitting SHOP_REVIEW_MODE. Revoke or rotate demo credentials after review. The password shared in chat should be rotated before inviting a reviewer.

The source code and this ZIP do not contain the supplied email/password. The installed JSON files are local-only and must not be committed or shared.
