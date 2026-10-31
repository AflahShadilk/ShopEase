$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$servicePath = 'lib/services/product_image_service.dart'
$controllerPath = 'lib/admin/controllers/product_form_controller.dart'
$sourcePath = 'migration_assets/product_image_service.dart'
foreach ($path in @($servicePath, $controllerPath, $sourcePath, 'pubspec.yaml')) {
  if (-not (Test-Path $path)) { throw "Missing $path - extract the ZIP into the ShopEase project root." }
}

$controller = [System.IO.File]::ReadAllText((Join-Path $root $controllerPath))
$oldCleanup = @'
      if (uploaded != null) {
        try {
          await imageService.deleteUploaded(uploaded.path);
        } catch (_) {
          // Cleanup is best effort if the Firestore write fails.
        }
      }
'@
$oldMessage = @'
      Get.snackbar('Save failed',
          'Check Storage access, admin permissions or Firestore. $error');
'@
$newMessage = @'
      if (uploaded != null) {
        debugPrint('Cloudinary image uploaded, but Firestore save failed. '
            'Review unused images in the Cloudinary Media Library.');
      }
      debugPrint('ShopEase product save failed: $error');
      Get.snackbar('Save failed',
          'Cloudinary image upload or Firestore save failed: $error');
'@

# Normalize line endings only for matching, preserve file through the backup.
$normalized = $controller.Replace("`r`n", "`n")
$oldCleanup = $oldCleanup.Replace("`r`n", "`n")
$oldMessage = $oldMessage.Replace("`r`n", "`n")
$newMessage = $newMessage.Replace("`r`n", "`n")
if ($normalized.Contains('await imageService.deleteUploaded(uploaded.path)')) {
  if (-not $normalized.Contains($oldCleanup)) {
    throw 'Product form cleanup differs from the known ShopEase version. No files changed; inspect controller manually.'
  }
  $normalized = $normalized.Replace($oldCleanup, '')
}
if ($normalized.Contains('Check Storage access, admin permissions or Firestore.')) {
  if (-not $normalized.Contains($oldMessage)) {
    throw 'Product form error message differs from expected source. No files changed; inspect controller manually.'
  }
  $normalized = $normalized.Replace($oldMessage, $newMessage)
} elseif (-not $normalized.Contains('Cloudinary image upload or Firestore save failed:')) {
  throw 'Could not locate the Save failed message. No files changed.'
}

$backup = Join-Path $env:TEMP ('ShopEaseCloudinaryBackup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Copy-Item $servicePath (Join-Path $backup 'product_image_service.dart') -Force
Copy-Item $controllerPath (Join-Path $backup 'product_form_controller.dart') -Force
Copy-Item 'pubspec.yaml' (Join-Path $backup 'pubspec.yaml') -Force

# The service contains no Firebase Storage integration, and preserves the
# existing ProductImageSelection and UploadedProductImage interfaces.
Copy-Item $sourcePath $servicePath -Force
[System.IO.File]::WriteAllText(
  (Join-Path $root $controllerPath),
  $normalized,
  (New-Object System.Text.UTF8Encoding($false))
)

Write-Host "Cloudinary migration installed. Backups: $backup" -ForegroundColor Green
Write-Host 'Run these from the ShopEase root:' -ForegroundColor Cyan
Write-Host '  flutter pub add http'
Write-Host '  flutter pub remove firebase_storage'
Write-Host '  dart format lib test/image_upload'
Write-Host '  powershell -ExecutionPolicy Bypass -File .\tools\check_cloudinary.ps1'
Write-Host 'Cloudinary config comes from --dart-define; never put an API secret in the app.' -ForegroundColor Yellow
