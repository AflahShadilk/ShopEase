$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
Write-Host 'ShopEase - Cloudinary migration checks' -ForegroundColor Cyan
$needed = @(
  'lib/services/product_image_service.dart',
  'lib/admin/controllers/product_form_controller.dart',
  'test/image_upload/cloudinary_migration_test.dart',
  'tools/install_cloudinary.ps1'
)
foreach ($p in $needed) {
  if (-not (Test-Path $p)) { throw "Missing: $p" }
}
$service = Get-Content 'lib/services/product_image_service.dart' -Raw
$controller = Get-Content 'lib/admin/controllers/product_form_controller.dart' -Raw
$pubspec = Get-Content 'pubspec.yaml' -Raw
if (-not $service.Contains('api.cloudinary.com') -or -not $service.Contains('upload_preset')) { throw 'Cloudinary upload service missing.' }
if ($service.Contains('firebase_storage')) { throw 'Firebase Storage is still imported in the upload service.' }
if ($controller.Contains('deleteUploaded')) { throw 'Old Firebase Storage cleanup still present.' }
if ($pubspec -match '(?m)^\s*firebase_storage\s*:') { throw 'Run flutter pub remove firebase_storage first.' }
if ($pubspec -notmatch '(?m)^\s*http\s*:') { throw 'Run flutter pub add http first.' }

flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed.' }
dart format --output=none --set-exit-if-changed lib test/image_upload
if ($LASTEXITCODE -ne 0) { throw 'Format check failed. Run dart format lib test/image_upload.' }
flutter test test/image_upload/ --reporter expanded
if ($LASTEXITCODE -ne 0) { throw 'Image unit/widget tests failed.' }
Write-Host 'PASS: Cloudinary migration checks and image tests.' -ForegroundColor Green
Write-Host 'Live Cloudinary upload and Firestore image rendering must still be tested manually.' -ForegroundColor Yellow
