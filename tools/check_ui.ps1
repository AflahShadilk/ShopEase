$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

function Run-Command($label, $program, [string[]]$arguments) {
  Write-Host "`n=== $label ===" -ForegroundColor Cyan
  & $program @arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$label failed (exit code $LASTEXITCODE). Fix the issue before committing."
  }
}

Write-Host 'ShopEase | Responsive UI and overflow checks' -ForegroundColor Yellow

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter is not available in PATH. Open the Flutter SDK-enabled VS Code terminal.'
}
if (-not (Test-Path 'test/ui/shopease_responsive_test.dart')) {
  throw 'Missing test/ui/shopease_responsive_test.dart. Extract the UI Quality Add-on into the project root.'
}

Run-Command 'UI test Dart formatting' 'dart' @('format', '--output=none', '--set-exit-if-changed', 'test/ui')
Run-Command 'Responsive and overflow widget tests' 'flutter' @('test', 'test/ui/', '--reporter', 'expanded')
Write-Host "`nPASS: Responsive widget smoke tests completed." -ForegroundColor Green
Write-Host 'NOTE: This does not check every live Firebase screen or every device.' -ForegroundColor Yellow
Write-Host 'Do the manual device-width and text-size checks in docs/UI_TEST_CHECKLIST.md.'
