# ShopEase - UI Quality Checklist

This checklist supplements the automated widget tests. `flutter analyze` cannot detect a RenderFlex overflow, and the widget test suite only renders the selected reusable components with sample data. Test the real screens too.

## Run automatically (every feature)

From the project root in VS Code PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\check_all.ps1
```

This runs:
1. `check_design_getx.ps1` - project theme, shared widgets, GetX and no `setState`.
2. `check_products.ps1` - expected product files, `flutter analyze`, formatting and git whitespace.
3. `check_ui.ps1` - `flutter test test/ui/` at phone/tablet/desktop widths with normal and enlarged text.

A non-zero exit code means it failed: fix errors before committing. These tests do not need a live Firebase connection.

## Manual responsive UI checks (every new screen)

Run customer: `flutter run -d chrome -t lib/main.dart`
Run admin: `flutter run -d chrome -t lib/main_admin.dart`

In Chrome press F12 -> device toolbar (`Ctrl + Shift + M`), then check widths:
- 320 x 720 - small Android phone
- 360 x 800 - common Android phone
- 390 x 844 - larger phone
- 600 x 960 - small tablet
- 768 x 1024 - tablet
- 1024 x 768 - landscape tablet/small laptop
- 1440 x 900 - desktop

For every screen check:
- No yellow/black overflow bands and no `A RenderFlex overflowed` message in debug console.
- No clipped bottom buttons/labels; forms scroll when keyboard opens.
- No horizontal scrolling unless intended (e.g. product carousel).
- Text stays readable at 100%, 130%, and 200% system/browser text scaling; 200% may expose layout issues to fix.
- Product cards fit their grid cell and long product names do not escape boundaries.
- Buttons have adequate tap size (aim >= 48x48 logical pixels) and are not hidden behind keyboard.
- Errors, loading, empty catalog and offline views look correct.
- Contrast and focus indicators are usable; icons have accessible tooltips/labels.
- Long email addresses, large prices, empty images and slow image loading do not break layout.
- Verify portrait/landscape for phone and tablet.
- Re-test after changing ThemeData, font sizes or shared widgets.

## What to do when overflow appears

1. Capture width, height and text scale. Copy the exact `RenderFlex overflowed by ... pixels` error.
2. Identify the overflowing Row/Column from the Flutter error.
3. Typical fixes: wrap flexible text in `Expanded` or `Flexible`, use `maxLines` with `TextOverflow.ellipsis`, replace a tight `Row` with `Wrap`, and make long forms scrollable.
4. If a fixed-height product card overflows at large text scale, increase the grid's `mainAxisExtent` or redesign card content. Don't solve this by hiding overflow with `ClipRect`.
5. Re-run `check_all.ps1`, then repeat the manual screen check.

## Interview summary

`flutter analyze` catches static Dart issues. `flutter test` can pump widgets at various viewport sizes; Flutter reports layout errors such as `RenderFlex overflowed` during the test. Manual device testing is still necessary for platform behavior, keyboard insets, data variations and accessibility.
