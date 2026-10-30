$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Test-Path '.\lib\main_admin.dart') -or -not (Test-Path '.\lib\services\order_service.dart')) {
  throw 'Run from ShopEase root with the Cart + Checkout feature installed.'
}
if (-not (Test-Path '.\lib\admin\screens\customers\admin_customers_screen.dart')) {
  throw 'Extract the ShopEase Customer Profiles + Tracking ZIP first.'
}

$backup = Join-Path $env:TEMP ('ShopEaseProfilesBackup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Edit-File([string]$file, [string]$anchor, [string]$replacement) {
  $resolved = (Resolve-Path $file).Path
  $content = [System.IO.File]::ReadAllText($resolved).Replace("`r`n", "`n")
  $anchor = $anchor.Replace("`r`n", "`n")
  $replacement = $replacement.Replace("`r`n", "`n")
  if ($content.Contains($replacement)) {
    Write-Host "Already updated: $file" -ForegroundColor Yellow
    return
  }
  if (-not $content.Contains($anchor)) {
    throw "Expected anchor missing in $file. Nothing changed in this file; see backup: $backup"
  }
  $name = $file.Replace('/', '_').Replace('\', '_')
  $path = Join-Path $backup $name
  if (-not (Test-Path $path)) {
    [System.IO.File]::WriteAllText($path, $content, $utf8)
  }
  $updated = $content.Replace($anchor, $replacement)
  [System.IO.File]::WriteAllText($resolved, $updated, $utf8)
  Write-Host "Updated $file" -ForegroundColor Green
}

Edit-File 'lib/main_admin.dart' "import 'services/order_service.dart';" @'
import 'services/order_service.dart';
import 'services/customer_directory_service.dart';
import 'admin/controllers/admin_customers_controller.dart';
'@

Edit-File 'lib/main_admin.dart' '  runApp(const ShopEaseAdminApp());' @'
  final directoryService = Get.put(CustomerDirectoryService(), permanent: true);
  Get.put(
    AdminCustomersController(service: directoryService, session: session),
    permanent: true,
  );
  runApp(const ShopEaseAdminApp());
'@

Edit-File 'lib/admin/screens/products/admin_products_screen.dart' "import '../orders/admin_orders_screen.dart';" @'
import '../orders/admin_orders_screen.dart';
import '../customers/admin_customers_screen.dart';
'@

Edit-File 'lib/admin/screens/products/admin_products_screen.dart' @'
        actions: [
'@ @'
        actions: [
          IconButton(
            tooltip: 'Customer profiles',
            icon: const Icon(Icons.people_alt_outlined),
            onPressed: () => Get.to<void>(() => const AdminCustomersScreen()),
          ),
'@

Edit-File 'lib/customer/screens/orders/shop_orders_screen.dart' "import '../../../core/theme/shop_colors.dart';" @'
import '../../../core/theme/shop_colors.dart';
import '../../../core/widgets/shop_order_timeline.dart';
'@

Edit-File 'lib/customer/screens/orders/shop_orders_screen.dart' @'
            Text(order.shippingAddress,
                style: const TextStyle(color: ShopColors.muted)),
'@ @'
            Text(order.shippingAddress,
                style: const TextStyle(color: ShopColors.muted)),
            const Divider(height: 30),
            ShopOrderTimeline(status: order.status),
'@

Write-Host "`nCustomer profiles and tracking integrated." -ForegroundColor Green
Write-Host "Backups: $backup"
Write-Host 'Run: dart format lib test/profiles; flutter analyze; flutter test test/profiles'
Write-Host 'Existing Firestore rules already support admin reads of customers and orders. Review them before deployment.' -ForegroundColor Yellow
