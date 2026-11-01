# ShopEase — Release Readiness Kit

**Branch:** `feature/release-readiness`

Designed for the ShopEase Flutter/Firebase machine-test project, based on product image upload commit `7a7510c` and all preceding features. This kit does not change the customer/admin UI, GetX state management, Firestore rules, or Storage rules.

## What the kit adds

- A Windows PowerShell installer that adds Android release INTERNET permission (required for Firebase network calls), a hosting target for the **admin web app** while preserving FlutterFire settings, and ignores build exports.
- A replacement for the stale Flutter counter-template widget test; the replacement tests an actual ShopEase product card without initializing Firebase.
- A complete release verification script that analyzes and tests the *whole* project.
- A packaging script that builds the customer Android demo APK (`lib/main.dart`) and admin web zip (`lib/main_admin.dart`) and produces a SHA-256 report.
- Optional GitHub Actions CI workflow for tests and artifacts; does not deploy or access production credentials.
- Submission and Firebase security checklists.

## Install in VS Code PowerShell (one line per command)

```powershell
cd C:\flutterDev\projects\shopease
git status
git fetch origin
git switch -c feature/release-readiness --track origin/feature/release-readiness
Expand-Archive -Path "$HOME\Downloads\ShopEase_Release_Readiness_Kit.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force
powershell -ExecutionPolicy Bypass -File .\tools\install_release_readiness.ps1
dart format lib test
powershell -ExecutionPolicy Bypass -File .\tools\check_release_readiness.ps1
powershell -ExecutionPolicy Bypass -File .\tools\build_submission.ps1
```

If the branch already exists locally, use `git switch feature/release-readiness` instead of `git switch -c`. The installer **backs up files to your Windows TEMP directory** before edits. Do not run `git switch` with uncommitted work you want to keep.

The outputs will be in a local `submission/` directory (ignored by Git):

- `shopease-customer-demo.apk` — Android release-mode build using the project's current **debug-key signing configuration**, *not* a Play Store production release.
- `shopease-admin-web.zip` — extracted web build can be hosted from `build/web` or the ZIP.
- `BUILD_REPORT.txt` — build artifacts and SHA-256 checksums.

To build only one target, use `-SkipAndroid` or `-SkipWeb`. To avoid repeating tests *after they have passed*, use `-SkipChecks`.

## Admin web Firebase Hosting

The installer adds a `hosting` section to `firebase.json` only if absent and creates `.firebaserc` only if absent. Existing FlutterFire configuration stays intact. It does not deploy automatically.

To deploy the **admin web app** only, after verifying your Firebase project/account and building web:

```powershell
npm install -g firebase-tools
firebase login
firebase use shopease-1e20b
firebase deploy --only hosting
```

**Caution:** If Firebase Hosting already has a live website in that target, deployment replaces its hosted content. Confirm your target before running the deploy command. The customer mobile APK does not need Hosting.

## Known limitations to disclose

- The COD checkout is a demonstration. Product prices and stock need **trusted backend validation** for commercial use; order requests alone do not reserve or deduct stock.
- Firebase Storage upload cannot be verified through widget tests. It requires an enabled bucket, appropriate billing, and deployed Storage rules. The HTTPS image URL option remains available.
- The Android build is signed with **debug keys** according to `android/app/build.gradle`. It is installable for a machine-test demo, but not suitable as a Play Store submission. A proper release keystore and package identity are separate work.
- Actual sign-in, Firestore access and Storage/Hosting permissions must be checked on real devices/accounts.

Read `docs/FINAL_SUBMISSION_CHECKLIST.md` and `docs/REVIEWER_GUIDE.md` before submitting.
