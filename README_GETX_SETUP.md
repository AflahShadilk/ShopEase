# ShopEase / GetX Authentication Starter

This is a revised, GetX-only state-management patch for the existing Flutter repository `AflahShadilk/ShopEase` on `feature/auth`. It supersedes the previous `shopease_auth_patch.zip`. Use this ZIP instead of the previous patch. If you already extracted the old patch, this one overwrites its affected files safely.

## Decision

- State management: `get` stable (GetX), `GetxController`, `.obs`, `Obx`, `ObxValue`.
- Dependency injection: `Get.put`/`Get.find`.
- Navigation: `GetMaterialApp`, `Get.to`, `Get.off`, `Get.offAll`.
- Firebase Auth and Firestore remain backend services, **not** state managers.
- No `setState` or `StatefulWidget` in patch files. Flutter's framework still manages its internal widget state.
- Shared theme remains **Dragonfruit x Yuzu**; existing reusable widgets remain intact except for the `ShopTextField` conversion.

## Install on Windows / VS Code

```powershell
cd C:\flutterDev\projects\shopease
git status
git switch feature/auth
flutter pub remove provider
flutter pub add get
```

Extract `shopease_getx_auth_patch.zip` into the project **root** (not into `lib/`):

```powershell
Expand-Archive -Path "$HOME\Downloads\shopease_getx_auth_patch.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force
```

The root of the archive contains `lib/`, `firestore.rules`, and `README_GETX_SETUP.md`. Existing `firebase_options.dart` is left unchanged. Do not delete the existing `core/theme` or other design system widgets. If you applied the old auth patch already, these files will replace the affected files.

## Firebase setup and security

- Firebase Console -> Authentication -> Sign-in method -> **Enable Email/Password**.
- Firebase Console -> Firestore Database -> Rules -> carefully review and publish `firestore.rules`. These rules are intentionally **users-only** and deny product/orders access until their security rules are implemented. Merge carefully if you've already added those collections.
- Customer registration creates `users/{uid}` with immutable `role: customer`.
- To create a test admin, use Firebase Console Authentication to add a user, then Firebase Console Firestore to add `users/{uid}` with that UID and the following fields: `uid`, `name`, `email`, `role = admin`, `createdAt` timestamp. Never create admins in customer-facing code.
- Client-side GetX checks only decide what to *show*; Firestore security rules decide what users can actually read/write.

## Test

```powershell
flutter pub get
flutter analyze
flutter run -d chrome -t lib/main.dart
flutter run -d chrome -t lib/main_admin.dart
```

Run one web app at a time. To test Android when the build issue/device is resolved, use `flutter run -t lib/main.dart` with a connected device.

Test: password reveal, validation, registration, login, logout, refresh while authenticated, wrong password, customer denied admin panel, real admin granted admin panel.

**Registration note:** Firebase Auth creates the user before Firestore writes `users/{uid}`. A Firestore permission failure may leave an Auth user without a profile. Repair using Firebase Console or retry with a different test email once security rules are correct.

## Commit on the existing branch

```powershell
git status
git add lib pubspec.yaml pubspec.lock firestore.rules README_GETX_SETUP.md
git diff --cached --stat
git commit -m "refactor(auth): migrate auth and splash state to GetX"
git push -u origin feature/auth
```

Do not merge to `main` before `flutter analyze` and authentication tests succeed.
