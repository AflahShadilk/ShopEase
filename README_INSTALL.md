# ShopEase UI Quality Add-on

Only adds `test/ui/shopease_responsive_test.dart`, `tools/check_ui.ps1`, `tools/check_all.ps1` and `docs/UI_TEST_CHECKLIST.md`.
It does not overwrite the existing ShopEase theme, colors, widgets, GetX controllers, Firebase code or the two original checking scripts.

## Install

1. Ensure the GetX-aligned product kit has already been added to the ShopEase project.
2. Extract this ZIP into `C:\flutterDev\projects\shopease` (preserving directory structure).
3. In VS Code PowerShell run:

```powershell
cd C:\flutterDev\projects\shopease
powershell -ExecutionPolicy Bypass -File .\tools\check_design_getx.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check_products.ps1
powershell -ExecutionPolicy Bypass -File .\tools\check_ui.ps1
```

Or run all three with **one command**:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\check_all.ps1
```

If a responsive test fails, inspect the actual widget and fix it. Don't simply delete the failing test.

## After tests pass

```powershell
git add test/ui tools/check_ui.ps1 tools/check_all.ps1 docs/UI_TEST_CHECKLIST.md README_INSTALL.md
git diff --cached --stat
git commit -m "test(ui): add responsive overflow tests and consolidated checks"
git push origin feature/products
```

This package has not been executed against Flutter in this environment; run it in your local Flutter SDK and share errors if needed.
