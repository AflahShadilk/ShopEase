$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

$checks = @(
  'tools/check_design_getx.ps1',
  'tools/check_products.ps1',
  'tools/check_ui.ps1'
)

foreach ($script in $checks) {
  if (-not (Test-Path $script)) {
    throw "Missing $script. Install the GetX-aligned product kit and the UI Quality Add-on."
  }
  Write-Host "`n========== $script ==========" -ForegroundColor Cyan
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script
  if ($LASTEXITCODE -ne 0) {
    throw "$script failed. Fix it before committing or pushing."
  }
}

Write-Host "`nALL CHECKS PASSED: GetX/design + product/static + responsive widget tests." -ForegroundColor Green
Write-Host 'Still manually verify live UI and Firebase flows before merging.' -ForegroundColor Yellow
