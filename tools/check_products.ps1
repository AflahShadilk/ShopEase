$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
Write-Host 'ShopEase | Product feature verification' -ForegroundColor Cyan

$required = @(
  'lib/main.dart', 'lib/main_admin.dart', 'lib/shared/auth_gate.dart',
  'lib/models/shop_product.dart', 'lib/services/product_service.dart',
  'lib/customer/controllers/customer_catalog_controller.dart',
  'lib/customer/screens/catalog/customer_catalog_screen.dart',
  'lib/admin/controllers/admin_products_controller.dart',
  'lib/admin/controllers/product_form_controller.dart',
  'lib/admin/screens/products/admin_products_screen.dart',
  'lib/admin/screens/products/product_form_screen.dart',
  'lib/core/widgets/shop_editor_layout.dart',
  'firestore.rules'
)
foreach ($file in $required) {
  if (-not (Test-Path $file)) { throw "Missing file: $file" }
  Write-Host "FOUND $file"
}

$dartFiles = $required | Where-Object { $_ -like '*.dart' }
foreach ($file in $dartFiles) {
  if (Select-String -Path $file -Pattern 'setState\s*\(' -Quiet) {
    throw "Unexpected setState usage in $file"
  }
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter CLI not found. Run this from a VS Code terminal with Flutter on PATH.'
}

flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed' }
dart format --output=none --set-exit-if-changed lib
if ($LASTEXITCODE -ne 0) { throw 'Dart formatting check failed. Run dart format lib and retry.' }
git diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff whitespace check failed' }
git status --short
Write-Host 'Static checks passed. Still run both apps and the manual security tests.' -ForegroundColor Green
