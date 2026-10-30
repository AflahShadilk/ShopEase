# Cart + Checkout — interview explanation

- `CustomerCartController` (GetX): reactive `RxMap<String, ShopCartLine>`, add/remove/change quantity, calculates totals. The cart belongs to the current session and clears when account changes. Live catalog updates refresh prices/stock and remove unavailable items.
- `ShopCartLine` (Dart model): immutable product snapshot + quantity; computes a line total.
- `OrderService` (Firebase): reads current product docs inside a client Firestore transaction, rejects inactive/out-of-stock selections, writes a **pending cash-on-delivery request**. A client transaction does **not** reserve stock, and its values are not trusted for fulfillment.
- `ShopCheckoutController` (GetX): owns form text controllers, validation, loading and errors; `Obx` rebuilds relevant UI only.
- `CustomerOrdersController` (GetX): observes the signed-in customer's own `orders` query; resubscribes when account/profile changes.
- `AdminOrdersController` (GetX): admin-only stream and status updates; actual authorization enforced by Firestore rules, not by hidden buttons.
- `ShopCartItemTile` and `ShopCheckoutLayout`: reusable widgets using the existing Dragonfruit × Yuzu design tokens. Responsive widget tests cover 320/375/768/1280 widths and 1.3× text.
- No online payments; no claim that COD was delivered or charged.

**Common interviewer question:** Why are Firestore rules not enough to validate the checkout subtotal? Rules cannot safely aggregate and verify arbitrary list-item prices across product documents or reserve inventory across concurrent orders. Production needs a trusted backend/Cloud Function to recompute prices, reserve stock atomically and verify payment or COD fulfillment.
