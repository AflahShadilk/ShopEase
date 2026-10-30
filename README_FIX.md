# ShopEase responsive overflow fix

Targeted fix for two failing UI tests:

- `Admin editor: 320px, text 1.3` — 26 px right overflow
- `Auth form: 1024px, text 1.3` — 100 px bottom overflow

## What changed

- `lib/core/widgets/shop_editor_layout.dart`: reduce outer and form-card horizontal padding on screens narrower than 400 logical pixels, giving text fields room to render.
- `lib/core/widgets/shop_auth_layout.dart`: use a single-column layout below 1120 px; remove the brand panel's fixed height and `Spacer` widgets so text can wrap without a vertical Flex overflow.

Both files reuse **ShopColors**, **ShopBrand** and the existing ShopEase theme. They are `StatelessWidget`s; no `setState`, new state management, or new dependencies were introduced.

## Windows PowerShell

Only extract once your current branch is `feature/products`. Save a backup of any local customization first.

```powershell
cd C:\flutterDev\projects\shopease
git branch --show-current
git diff -- lib/core/widgets/shop_editor_layout.dart lib/core/widgets/shop_auth_layout.dart
Expand-Archive -Path "$HOME\Downloads\ShopEase_Overflow_Fix.zip" -DestinationPath "C:\flutterDev\projects\shopease" -Force
dart format lib/core/widgets/shop_editor_layout.dart lib/core/widgets/shop_auth_layout.dart
flutter analyze
flutter test test/ui/shopease_responsive_test.dart
powershell -ExecutionPolicy Bypass -File .\tools\check_all.ps1
```

## If a test still fails

The existing UI test catches the first Flutter exception and outputs a short error. To diagnose the offending widget, temporarily insert `debugPrint(error?.toStringDeep());` immediately above `expect(error, isNull, ...)` in `test/ui/shopease_responsive_test.dart`, then rerun the one failing test with `flutter test test/ui/shopease_responsive_test.dart --plain-name "Admin editor: 320px, text 1.3"`.

## Manual checks

Open the admin and customer apps in Chrome. Confirm the admin editor at 320 px width, the login page at 1024 px, scrolling, keyboard overlays, large text scaling, and both forms on a small device. Automated tests do not guarantee every route has no overflow.

## Interview explanation

`RenderFlex` overflow happens when a `Row` or `Column` does not have enough space for its children. Here we use width breakpoints and flexible-height layouts instead of shrinking fonts or suppressing the test. `SingleChildScrollView` allows tall forms to scroll; it cannot fix a child Row that is already too wide.
