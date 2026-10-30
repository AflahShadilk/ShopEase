$ErrorActionPreference = 'Stop'
$files = @(
  'lib/models/shop_customer.dart',
  'lib/services/customer_directory_service.dart',
  'lib/admin/controllers/admin_customers_controller.dart',
  'lib/admin/controllers/admin_customer_orders_controller.dart',
  'lib/admin/screens/customers/admin_customers_screen.dart',
  'lib/admin/screens/customers/admin_customer_detail_screen.dart',
  'lib/core/widgets/shop_customer_card.dart',
  'lib/core/widgets/shop_order_timeline.dart',
  'test/profiles/profiles_logic_test.dart',
  'test/profiles/profiles_responsive_test.dart'
)
foreach ($file in $files) {
  if (-not (Test-Path $file)) { throw "Missing: $file" }
}

function Assert-Exit([string]$name) {
  if ($LASTEXITCODE -ne 0) { throw "$name failed (exit code $LASTEXITCODE)." }
}

flutter analyze
Assert-Exit 'flutter analyze'
dart format --output=none --set-exit-if-changed lib test/profiles
Assert-Exit 'dart format'
flutter test test/profiles/ --reporter expanded
Assert-Exit 'Profile and tracking widget tests'
Write-Host 'PASS: Customer profiles + tracking static/widget checks.' -ForegroundColor Green
Write-Host 'Manually verify admin Firestore access, order history, tracking, and privacy rules.' -ForegroundColor Yellow
