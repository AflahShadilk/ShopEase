# ShopEase — Cart + Checkout feature kit

**Target repository:** `AflahShadilk/ShopEase`

**Base:** `feature/products` commit `98eb96f`.

**New GitHub branch:** `feature/cart-checkout` (already created remotely from that commit).

## Installation — VS Code PowerShell, project root

1. Make sure `git status` is clean on your previous feature.
2. `git fetch origin`
3. `git switch -c feature/cart-checkout --track origin/feature/cart-checkout`
4. Extract **this ZIP** into `C:\flutterDev\projects\shopease` with `Expand-Archive -Path "$HOME\Downloads\ShopEase_Cart_Checkout_GetX.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force`
5. `powershell -ExecutionPolicy Bypass -File .\tools\install_cart_checkout.ps1`
6. `dart format lib test/cart`
7. `flutter analyze`
8. `flutter test test/cart/`
9. `powershell -ExecutionPolicy Bypass -File .\tools\check_cart_checkout.ps1`
10. `powershell -ExecutionPolicy Bypass -File .\tools\check_all.ps1`

**The installer patches existing files by exact anchors and creates backups under your Windows TEMP folder.** It never publishes Firebase rules or commits automatically. If an anchor is not found, it stops with an error; inspect your local changes before retrying. It is designed specifically for the stated base commit.

## Firebase

Updated `firestore.rules` in the project must be reviewed and published in Firebase Console > Firestore Database > Rules. Use an admin login and customer login in separate browser profiles. Ensure customer can create only a pending COD order and read only their own orders; ensure admin can read and update status. See `docs/CART_CHECKOUT_TEST_PLAN.md`.

## Purpose and limitations

- GetX cart with live price/availability refresh and stock-aware quantity controls.
- Demo cash-on-delivery checkout, order request stored in Firestore.
- Customer order history and admin order status management.
- **Important:** This is a machine-test demo, not a payment-ready commerce backend. The Firestore write is customer-originated: it does **not** guarantee trusted prices/totals, prevent multi-user overselling, reserve inventory, enforce item-by-item validation in security rules, or charge money. Admin must independently verify stock, prices and fulfillment. For production, use a trusted Cloud Function / backend endpoint to calculate the amount, reserve/decrement stock transactionally, and create a validated order.
- Cart is in-memory and resets on sign-out or switching accounts. It does not persist between app restarts.
- No payment-gateway integration and no real payment processing.

## After tests

Manually test Android and Chrome at 320/375/768/1280 logical pixels, including 1.3× text scaling, login, empty cart, stock changes, order submission and status updates. When satisfied, run `git status`, `git diff --check`, `git add -A`, `git commit -m "feat(cart): add GetX cart, COD checkout and orders"`, `git push -u origin feature/cart-checkout`. Avoid merging until live Firebase flows work.
