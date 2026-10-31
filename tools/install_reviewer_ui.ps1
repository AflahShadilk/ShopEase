$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$assets = Join-Path $root 'review_patch_assets'
if (-not (Test-Path $assets)) { throw 'review_patch_assets folder not found. Extract the entire kit to your ShopEase root first.' }
if (-not (Test-Path 'lib/shared/screens/shop_login_screen.dart')) { throw 'Not in the expected ShopEase repo.' }
if (-not (Test-Path 'lib/services/product_image_service.dart')) { throw 'Cloudinary migration service not found.' }
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backup = Join-Path $env:TEMP ('ShopEaseReviewerUIBackup_' + $stamp)
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$files = @(
  'lib/admin/screens/products/admin_products_screen.dart',
  'lib/admin/widgets/admin_product_row.dart',
  'lib/shared/shop_splash_screen.dart',
  'lib/core/config/shop_reviewer_login.dart',
  'lib/shared/controllers/shop_login_controller.dart',
  'lib/shared/screens/shop_login_screen.dart',
  'test/ui/admin_product_row_test.dart',
  'test/ui/reviewer_login_config_test.dart'
)
foreach ($path in $files) {
  $src = Join-Path $assets $path
  $dst = Join-Path $root $path
  if (-not (Test-Path $src)) { throw "Missing patch file $path" }
  if (Test-Path $dst) {
    $b = Join-Path $backup $path
    New-Item -ItemType Directory -Path (Split-Path -Parent $b) -Force | Out-Null
    Copy-Item $dst $b -Force
  }
  New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
  Copy-Item $src $dst -Force
  Write-Host "Updated $path"
}
$gitignore = Join-Path $root '.gitignore'
if (-not (Test-Path $gitignore)) { New-Item $gitignore -ItemType File | Out-Null }
$lines = Get-Content $gitignore
foreach ($entry in @('/config/cloudinary.json','/config/reviewer_admin.json','/config/reviewer_customer.json')) {
  if ($lines -notcontains $entry) { Add-Content $gitignore "`n$entry" }
}
Write-Host "`nReviewer UI patch installed. Backups: $backup" -ForegroundColor Green
Write-Host 'Original Cloudinary service, Firestore code, and android/app/build.gradle untouched.'
Write-Host 'Next: dart format lib test; flutter analyze; flutter test'
Write-Host 'Use dedicated demo accounts. --dart-define credentials are readable in the compiled web app.' -ForegroundColor Yellow
