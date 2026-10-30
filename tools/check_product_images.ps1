$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
Write-Host 'ShopEase | Product image upload checks'
$needed = @(
  'lib/services/product_image_service.dart',
  'lib/core/widgets/shop_image_picker_field.dart',
  'lib/admin/controllers/product_form_controller.dart',
  'lib/admin/screens/products/product_form_screen.dart',
  'test/image_upload/product_image_validation_test.dart',
  'test/image_upload/shop_image_picker_responsive_test.dart',
  'storage.rules'
)
foreach ($path in $needed) {
  if (-not (Test-Path $path)) { throw "Missing: $path" }
}
if (-not ((Get-Content 'lib/admin/screens/products/product_form_screen.dart' -Raw).Contains('ShopImagePickerField'))) {
  throw 'Image picker not wired to product form. Run installer.'
}
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed' }
dart format --output=none --set-exit-if-changed lib test/image_upload
if ($LASTEXITCODE -ne 0) { throw 'dart format check failed. Run dart format lib test/image_upload' }
flutter test test/image_upload/ --reporter expanded
if ($LASTEXITCODE -ne 0) { throw 'Image upload tests failed' }
Write-Host 'PASS: Static validation, responsive widget tests, and image checks.'
Write-Host 'NOTE: Cloud Storage uploads and security rules require LIVE manual verification.'
