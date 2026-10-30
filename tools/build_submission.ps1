param(
  [switch]$SkipChecks,
  [switch]$SkipAndroid,
  [switch]$SkipWeb
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if ($SkipAndroid -and $SkipWeb) { throw 'Both targets are disabled. Build at least one.' }

function Invoke-Checked([string]$label, [string]$executable, [string[]]$commandArgs) {
  Write-Host "`n=== $label ===" -ForegroundColor Cyan
  & $executable @commandArgs
  if ($LASTEXITCODE -ne 0) { throw "$label failed (exit code $LASTEXITCODE)." }
}

if (-not $SkipChecks) {
  $checkScript = Join-Path $root 'tools/check_release_readiness.ps1'
  Invoke-Checked 'Final code checks' 'powershell.exe' @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $checkScript)
}

$out = Join-Path $root 'submission'
New-Item -ItemType Directory -Path $out -Force | Out-Null
$entries = New-Object System.Collections.Generic.List[string]
$entries.Add('ShopEase machine-test build report')
$entries.Add('Created UTC: ' + [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))
$commit = (& git rev-parse --short HEAD 2>$null)
if ($LASTEXITCODE -eq 0) { $entries.Add('Git commit: ' + $commit) }
$entries.Add('Android APK uses project debug signing config; not Play Store-ready.')
$entries.Add('Web bundle is the ADMIN app, not the customer app.')
$entries.Add('')

if (-not $SkipAndroid) {
  Invoke-Checked 'Customer Android APK build' 'flutter' @('build', 'apk', '--release', '-t', 'lib/main.dart')
  $apk = Join-Path $root 'build/app/outputs/flutter-apk/app-release.apk'
  if (-not (Test-Path $apk)) { throw "Flutter APK build finished but artifact is missing: $apk" }
  $destination = Join-Path $out 'shopease-customer-demo.apk'
  Copy-Item $apk $destination -Force
  $hash = (Get-FileHash -Algorithm SHA256 -Path $destination).Hash
  $entries.Add('shopease-customer-demo.apk | ' + (Get-Item $destination).Length + ' bytes | SHA256 ' + $hash)
  Write-Host "Saved customer APK: $destination" -ForegroundColor Green
}

if (-not $SkipWeb) {
  Invoke-Checked 'Admin Flutter web build' 'flutter' @('build', 'web', '--release', '-t', 'lib/main_admin.dart')
  $webDir = Join-Path $root 'build/web'
  if (-not (Test-Path (Join-Path $webDir 'index.html'))) { throw 'Admin web index.html missing after build.' }
  $destination = Join-Path $out 'shopease-admin-web.zip'
  if (Test-Path $destination) { Remove-Item $destination -Force }
  Compress-Archive -Path (Join-Path $webDir '*') -DestinationPath $destination -CompressionLevel Optimal
  $hash = (Get-FileHash -Algorithm SHA256 -Path $destination).Hash
  $entries.Add('shopease-admin-web.zip | ' + (Get-Item $destination).Length + ' bytes | SHA256 ' + $hash)
  Write-Host "Saved admin web ZIP: $destination" -ForegroundColor Green
}

$report = Join-Path $out 'BUILD_REPORT.txt'
[System.IO.File]::WriteAllLines($report, $entries.ToArray(), (New-Object System.Text.UTF8Encoding($false)))
Write-Host "`nBuild report saved: $report" -ForegroundColor Green
Write-Host 'Do not submit until you install the APK, test the admin web, and manually verify Firebase access and rules.' -ForegroundColor Yellow
