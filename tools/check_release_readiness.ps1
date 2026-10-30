$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Invoke-Checked([string]$label, [string]$executable, [string[]]$commandArgs) {
  Write-Host "`n=== $label ===" -ForegroundColor Cyan
  & $executable @commandArgs
  if ($LASTEXITCODE -ne 0) { throw "$label failed (exit code $LASTEXITCODE)." }
}

$mustExist = @(
  'lib/main.dart', 'lib/main_admin.dart', 'lib/firebase_options.dart',
  'lib/services/auth_service.dart', 'lib/services/order_service.dart',
  'lib/services/product_image_service.dart', 'firestore.rules', 'storage.rules',
  'test/ui', 'test/cart', 'test/profiles', 'test/image_upload'
)
foreach ($path in $mustExist) { if (-not (Test-Path $path)) { throw "Missing required file: $path" } }

$manifest = Get-Content 'android/app/src/main/AndroidManifest.xml' -Raw
if (-not $manifest.Contains('android.permission.INTERNET')) {
  throw 'Android release internet permission missing. Run install_release_readiness.ps1.'
}
$config = Get-Content 'firebase.json' -Raw | ConvertFrom-Json
if ($null -eq $config.hosting) {
  throw 'Firebase Hosting config missing. Run install_release_readiness.ps1.'
}
if (-not (Test-Path 'test/widget_test.dart')) { throw 'Widget smoke test missing.' }

Invoke-Checked 'Flutter dependencies' 'flutter' @('pub', 'get')
Invoke-Checked 'Flutter analyzer' 'flutter' @('analyze')
Invoke-Checked 'Dart formatting check' 'dart' @('format', '--output=none', '--set-exit-if-changed', 'lib', 'test')
Invoke-Checked 'All Flutter tests (including legacy smoke replacement)' 'flutter' @('test', '--reporter', 'expanded')
Invoke-Checked 'Git whitespace checks' 'git' @('diff', '--check')

Write-Host "`nALL RELEASE STATIC AND FLUTTER TEST CHECKS PASSED." -ForegroundColor Green
Write-Host 'Still verify Firebase rules, login roles, live storage, order behavior, APK install and browser deployment manually.' -ForegroundColor Yellow
