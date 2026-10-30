$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$branch = (git branch --show-current).Trim()
if ($branch -ne 'feature/product-image-upload') {
  throw "Expected feature/product-image-upload. Current branch: $branch. Switch branches first."
}

$controller = 'lib/admin/controllers/product_form_controller.dart'
$screen = 'lib/admin/screens/products/product_form_screen.dart'
$required = @(
  $controller,
  $screen,
  'lib/services/product_image_service.dart',
  'lib/core/widgets/shop_image_picker_field.dart',
  'storage.rules'
)
foreach ($path in $required) {
  if (-not (Test-Path $path)) { throw "Missing: $path. Extract the entire ZIP into project root." }
}

if ((Get-Content $screen -Raw).Contains('ShopImagePickerField')) {
  Write-Host 'Product image feature was already installed. No files replaced.'
  Write-Host 'Run: flutter pub add image_picker; dart format lib test/image_upload; flutter analyze'
  exit 0
}

$dirty = @(git status --porcelain -- $controller $screen)
if ($dirty.Length -gt 0) {
  throw 'Product form or controller has uncommitted edits. Save/commit those edits before installing to avoid overwriting them.'
}

$sourceController = Get-Content $controller -Raw
$sourceScreen = Get-Content $screen -Raw
if (-not ($sourceController.Contains('class ProductFormController') -and
           $sourceController.Contains('ProductService service;') -and
           $sourceScreen.Contains('class ProductFormScreen') -and
           $sourceScreen.Contains('ShopEditorLayout(') -and
           $sourceScreen.Contains('Image URL (optional)'))) {
  throw 'Product form differs from the expected GetX base. No files changed.'
}

$patchController = 'patches/lib/admin/controllers/product_form_controller.dart'
$patchScreen = 'patches/lib/admin/screens/products/product_form_screen.dart'
if (-not ((Test-Path $patchController) -and (Test-Path $patchScreen))) {
  throw 'Missing patch templates. Extract the entire ZIP before running installer.'
}

$backup = Join-Path $env:TEMP ("ShopEaseImageBackup_" + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Force -Path $backup | Out-Null
Copy-Item $controller (Join-Path $backup 'product_form_controller.dart')
Copy-Item $screen (Join-Path $backup 'product_form_screen.dart')
Copy-Item $patchController $controller -Force
Copy-Item $patchScreen $screen -Force

# Keep only the runnable feature code; templates need not go into the Git commit.
Remove-Item -Recurse -Force 'patches'
Write-Host ''
Write-Host 'Product image upload integrated. Backups:' $backup
Write-Host 'NEXT (run one at a time):'
Write-Host 'flutter pub add image_picker'
Write-Host 'dart format lib test/image_upload'
Write-Host 'flutter analyze'
Write-Host 'flutter test test/image_upload/'
Write-Host 'powershell -ExecutionPolicy Bypass -File .\tools\check_product_images.ps1'
Write-Host 'PUBLISH storage.rules in Firebase Storage Rules before uploading (Blaze plan required).'
