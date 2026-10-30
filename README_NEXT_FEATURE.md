# ShopEase | Feature 02 — Admin Products + Customer Catalog

**Branch:** `feature/products`  
**Requires:** the **GetX authentication patch already installed**, Firebase Auth and Firestore operational, a real test-admin profile with role `admin`.

This patch was prepared against the `AflahShadilk/ShopEase` GetX authentication package and your Dragonfruit × Yuzu widgets. It does **not** contain or replace `firebase_options.dart`.

## What it adds

- An admin products dashboard: view, add, edit, publish/hide, delete.
- A responsive customer product catalog and a small product-details bottom sheet.
- Firestore real-time streams that update the UI automatically.
- GetX controllers and reactive loading/error/empty states; no `setState`.
- A product model, Firebase product service, and **merged users + products Firestore security rules**.
- Terminal checklist, manual test plan and interview guide.

**Boundary:** This package uses an optional HTTPS image URL, not Firebase Storage uploads. Your Firebase project screenshot showed the Spark plan. Firebase Cloud Storage requires Blaze; we will add a proper upload workflow when billing is intentionally enabled. No cart, checkout, or order logic is included yet. Admin delete is permanent and not suitable for products that already have orders; once checkout is built, prefer archiving instead.

## 1. Before installing

From VS Code PowerShell in your repository:

```powershell
cd C:\flutterDev\projects\shopease
git status
git branch --show-current
```

**First complete and test the GetX authentication patch** on `feature/auth`, then commit and push it. Merge the tested feature into `main` using a GitHub pull request.

```powershell
git switch main
git pull --ff-only origin main
git switch -c feature/products
```

If your `feature/products` branch already exists, use `git switch feature/products` instead of creating it. Do not switch with uncommitted changes.

## 2. Extract the product kit

Download `ShopEase_Product_Feature.zip` into Windows Downloads, then:

```powershell
Expand-Archive -Path "$HOME\Downloads\ShopEase_Product_Feature.zip" `
  -DestinationPath "C:\flutterDev\projects\shopease" -Force
```

This overwrites `lib/main.dart`, `lib/main_admin.dart`, `lib/shared/auth_gate.dart`, and `firestore.rules` from the **GetX** authentication patch. It adds the product files. Review `git diff` after extraction. Never apply it to the original non-GetX version.

## 3. Firestore security rules

In Firebase Console -> Firestore Database -> Rules, **review and publish** the supplied `firestore.rules`. It keeps the previous users rules and adds product permissions. Do not overwrite a more advanced existing rules file without carefully merging it. Other collections (including `orders`) remain denied.

The `users/{uid}` record for your test administrator must already exist with `role = admin`; create/administer it using Firebase Console (never expose admin creation in customer UI). Ensure you are testing with an admin whose email/UID match the Authentication record.

## 4. Run analysis and apps

```powershell
flutter pub get
flutter analyze
dart format --output=none --set-exit-if-changed lib
flutter devices
flutter run -d chrome -t lib/main_admin.dart
```

Open another terminal (or stop the first) and run the customer UI:

```powershell
flutter run -d chrome -t lib/main.dart
```

**Note:** `dart format --output=none --set-exit-if-changed lib` may report formatting differences; run `dart format lib` then repeat the check. Your previous files may also need formatting.

The supplied `tools/check_products.ps1` runs non-interactive checks:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\check_products.ps1
```

Test flow: log in as admin, add a product, open the customer app with a **different customer account**, verify it appears, then change price/visibility. See `docs/PRODUCT_TEST_PLAN.md`.

## 5. Commit and push **after testing**

```powershell
git status
git diff --check
git add lib firestore.rules docs tools README_NEXT_FEATURE.md
git diff --cached --stat
git commit -m "feat(products): add admin management and customer catalog with GetX"
git push -u origin feature/products
```

Review and merge through a pull request after all tests pass. Never push service account JSON, private keys, tokens or passwords.

## Explain it in the interview

Read `docs/PRODUCT_FLOW_AND_INTERVIEW.md`. The five main concepts: product model, Firestore snapshot streams, GetX `.obs` / `Obx` / `ever`, access rules, and why Firebase Storage is a separate service.
