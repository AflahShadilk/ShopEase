$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$required = @(
  'lib/main.dart',
  'lib/main_admin.dart',
  'lib/firebase_options.dart',
  'lib/services/order_service.dart',
  'lib/services/product_image_service.dart',
  'android/app/src/main/AndroidManifest.xml',
  'android/app/build.gradle',
  'firebase.json',
  'test/widget_test.dart',
  'release_assets/widget_test.dart'
)
foreach ($path in $required) {
  if (-not (Test-Path $path)) { throw "Required ShopEase file missing: $path. Check branch and extracted ZIP." }
}

$backup = Join-Path $env:TEMP ('ShopEaseReleaseBackup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
foreach ($path in @('android/app/src/main/AndroidManifest.xml','firebase.json','.gitignore','test/widget_test.dart')) {
  if (Test-Path $path) {
    $name = ($path -replace '[/\\]', '__')
    Copy-Item -Path $path -Destination (Join-Path $backup $name) -Force
  }
}

# Android's debug/profile manifests can grant INTERNET only in development.
# For Android release builds, explicitly grant it in the main manifest.
$manifestPath = 'android/app/src/main/AndroidManifest.xml'
$manifest = [System.IO.File]::ReadAllText((Join-Path $root $manifestPath))
if (-not $manifest.Contains('android.permission.INTERNET')) {
  $pattern = '(<manifest\b[^>]*>)'
  if (-not [regex]::IsMatch($manifest, $pattern)) { throw 'Could not find the opening manifest tag.' }
  $manifest = [regex]::Replace($manifest, $pattern, '$1' + "`r`n" + '    <uses-permission android:name="android.permission.INTERNET" />')
  [System.IO.File]::WriteAllText((Join-Path $root $manifestPath), $manifest, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host 'Added Android release INTERNET permission.' -ForegroundColor Green
} else {
  Write-Host 'Android INTERNET permission already present.'
}

# Preserve the FlutterFire configuration, only add Hosting if not configured.
$configPath = Join-Path $root 'firebase.json'
$config = Get-Content $configPath -Raw | ConvertFrom-Json
if ($null -eq $config.hosting) {
  $hosting = [pscustomobject]@{
    public = 'build/web'
    ignore = @('firebase.json', '**/.*', '**/node_modules/**')
    rewrites = @([pscustomobject]@{ source = '**'; destination = '/index.html' })
  }
  $config | Add-Member -NotePropertyName 'hosting' -NotePropertyValue $hosting
  $content = $config | ConvertTo-Json -Depth 40
  [System.IO.File]::WriteAllText($configPath, ($content + "`n"), (New-Object System.Text.UTF8Encoding($false)))
  Write-Host 'Added admin web Hosting config without replacing FlutterFire settings.' -ForegroundColor Green
} else {
  Write-Host 'Firebase Hosting already configured. Existing target preserved.'
}

if (-not (Test-Path '.firebaserc')) {
  $rc = '{"projects":{"default":"shopease-1e20b"}}'
  [System.IO.File]::WriteAllText((Join-Path $root '.firebaserc'), ($rc + "`n"), (New-Object System.Text.UTF8Encoding($false)))
  Write-Host 'Created .firebaserc for the ShopEase Firebase project.'
} else {
  Write-Host 'Existing .firebaserc preserved. Verify the active project before deploying.'
}

# Replace the legacy counter-app widget test with a real ShopEase smoke test.
$oldTest = Get-Content 'test/widget_test.dart' -Raw
if ($oldTest.Contains('Counter increments smoke test') -or $oldTest.Contains('ShopEase product card displays product and price')) {
  Copy-Item 'release_assets/widget_test.dart' 'test/widget_test.dart' -Force
  Write-Host 'Installed the ShopEase product-card smoke test.'
} else {
  Write-Host 'Existing custom test/widget_test.dart preserved. Inspect it before running full tests.' -ForegroundColor Yellow
}

$ignore = '.gitignore'
if (-not (Test-Path $ignore)) { New-Item -ItemType File -Path $ignore | Out-Null }
$lines = Get-Content $ignore
if ($lines -notcontains '/submission/') {
  Add-Content -Path $ignore -Value "`n# Local machine-test submission bundles`n/submission/"
  Write-Host 'Excluded local submission builds from Git.'
}

Write-Host "`nRelease readiness installed. Backups: $backup" -ForegroundColor Green
Write-Host 'Run next: dart format lib test'
Write-Host 'Then: powershell -ExecutionPolicy Bypass -File .\tools\check_release_readiness.ps1'
Write-Host 'Then: powershell -ExecutionPolicy Bypass -File .\tools\build_submission.ps1'
Write-Host 'No builds or deployments have been run by this installer.' -ForegroundColor Yellow
