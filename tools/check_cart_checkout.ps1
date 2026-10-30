$ErrorActionPreference = 'Stop'
$required = @(
  'lib/models/shop_cart_line.dart',
  'lib/models/shop_order.dart',
  'lib/services/order_service.dart',
  'lib/customer/controllers/customer_cart_controller.dart',
  'lib/customer/controllers/customer_orders_controller.dart',
  'lib/customer/controllers/shop_checkout_controller.dart',
  'lib/customer/screens/cart/shop_cart_screen.dart',
  'lib/customer/screens/cart/shop_checkout_screen.dart',
  'lib/customer/screens/orders/shop_orders_screen.dart',
  'lib/admin/controllers/admin_orders_controller.dart',
  'lib/admin/screens/orders/admin_orders_screen.dart',
  'lib/core/widgets/shop_cart_item_tile.dart',
  'lib/core/widgets/shop_checkout_layout.dart',
  'test/cart/cart_logic_test.dart',
  'test/cart/cart_responsive_test.dart'
)
foreach ($path in $required) {
  if (-not (Test-Path $path)) { throw "Missing: $path" }
}
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed' }
dart format --output=none --set-exit-if-changed lib test/cart
if ($LASTEXITCODE -ne 0) { throw 'Dart format check failed. Run dart format lib test/cart.' }
flutter test test/cart/ --reporter expanded
if ($LASTEXITCODE -ne 0) { throw 'Cart tests failed' }
Write-Host 'Cart + Checkout checks passed. Now test Firebase and devices manually.' -ForegroundColor Green
