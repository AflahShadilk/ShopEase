$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
Write-Host 'ShopEase | Theme + GetX consistency check' -ForegroundColor Cyan

$required = @(
  'lib/core/theme/shop_theme.dart',
  'lib/core/theme/shop_colors.dart',
  'lib/core/widgets/shop_brand.dart',
  'lib/core/widgets/shop_button.dart',
  'lib/core/widgets/shop_text_field.dart',
  'lib/core/widgets/shop_editor_layout.dart',
  'lib/core/widgets/shop_product_card.dart',
  'lib/services/product_service.dart',
  'lib/admin/controllers/admin_products_controller.dart',
  'lib/admin/controllers/product_form_controller.dart',
  'lib/customer/controllers/customer_catalog_controller.dart'
)
foreach ($path in $required) {
  if (-not (Test-Path $path)) { throw "Missing: $path" }
}

$checks = @(
  @{File='lib/main.dart'; Pattern='GetMaterialApp'},
  @{File='lib/main_admin.dart'; Pattern='GetMaterialApp'},
  @{File='lib/main.dart'; Pattern='ShopTheme.light'},
  @{File='lib/main_admin.dart'; Pattern='ShopTheme.light'},
  @{File='lib/customer/screens/catalog/customer_catalog_screen.dart'; Pattern='ShopProductCard'},
  @{File='lib/admin/screens/products/product_form_screen.dart'; Pattern='ShopEditorLayout'},
  @{File='lib/admin/screens/products/product_form_screen.dart'; Pattern='ShopTextField'},
  @{File='lib/admin/screens/products/product_form_screen.dart'; Pattern='ShopButton'},
  @{File='lib/customer/controllers/customer_catalog_controller.dart'; Pattern='GetxController'},
  @{File='lib/admin/controllers/admin_products_controller.dart'; Pattern='GetxController'},
  @{File='lib/customer/screens/catalog/customer_catalog_screen.dart'; Pattern='Obx'},
  @{File='lib/admin/screens/products/admin_products_screen.dart'; Pattern='ShopColors'}
)
foreach ($check in $checks) {
  if (-not (Select-String -Path $check.File -Pattern ([regex]::Escape($check.Pattern)) -Quiet)) {
    throw "Expected '$($check.Pattern)' in $($check.File)"
  }
}

$featureFiles = Get-ChildItem 'lib/admin', 'lib/customer', 'lib/core/widgets/shop_editor_layout.dart', 'lib/core/widgets/shop_product_card.dart' -Recurse -File -Filter '*.dart'
foreach ($file in $featureFiles) {
  if (Select-String -Path $file.FullName -Pattern 'setState\s*\(' -Quiet) {
    throw "Found setState in $($file.FullName)"
  }
}

if (Select-String -Path 'pubspec.yaml' -Pattern '^  provider:' -Quiet) {
  Write-Warning 'Provider dependency remains. If unused, run flutter pub remove provider.'
}
Write-Host 'Design and GetX conventions verified (static checks only).' -ForegroundColor Green
