$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Test-Path '.\lib\main.dart')) {
  throw 'Run this command from the ShopEase repository root.'
}
if (-not (Test-Path '.\lib\customer\screens\cart\shop_cart_screen.dart')) {
  throw 'Extract the feature ZIP into the repository before running this installer.'
}

$backup = Join-Path $env:TEMP ('ShopEaseCartBackup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Edit-File([string]$file, [string]$anchor, [string]$replacement) {
  $content = [System.IO.File]::ReadAllText((Resolve-Path $file).Path).Replace("`r`n", "`n")
  $anchor = $anchor.Replace("`r`n", "`n")
  $replacement = $replacement.Replace("`r`n", "`n")
  if ($content.Contains($replacement)) {
    Write-Host "Already installed: $file" -ForegroundColor Yellow
    return
  }
  if (-not $content.Contains($anchor)) {
    throw "Could not find expected code in $file. File unchanged. Ask for a targeted patch."
  }
  $relative = $file.Replace('/', '_').Replace('\', '_')
  [System.IO.File]::WriteAllText((Join-Path $backup $relative), $content, $utf8)
  $content = $content.Replace($anchor, $replacement)
  [System.IO.File]::WriteAllText((Resolve-Path $file).Path, $content, $utf8)
  Write-Host "Updated $file" -ForegroundColor Green
}

Edit-File 'lib/main.dart' "import 'services/product_service.dart';" @'
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'customer/controllers/customer_cart_controller.dart';
import 'customer/controllers/customer_orders_controller.dart';
'@
Edit-File 'lib/main.dart' '  runApp(const ShopEaseApp());' @'
  final orderService = Get.put(OrderService(), permanent: true);
  Get.put(CustomerCartController(session: session), permanent: true);
  Get.put(CustomerOrdersController(service: orderService, session: session),
      permanent: true);
  runApp(const ShopEaseApp());
'@

Edit-File 'lib/main_admin.dart' "import 'services/product_service.dart';" @'
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'admin/controllers/admin_orders_controller.dart';
'@
Edit-File 'lib/main_admin.dart' '  runApp(const ShopEaseAdminApp());' @'
  final orderService = Get.put(OrderService(), permanent: true);
  Get.put(AdminOrdersController(service: orderService, session: session),
      permanent: true);
  runApp(const ShopEaseAdminApp());
'@

Edit-File 'lib/customer/controllers/customer_catalog_controller.dart' "import '../../models/shop_product.dart';" @'
import '../../models/shop_product.dart';
import 'customer_cart_controller.dart';
'@
Edit-File 'lib/customer/controllers/customer_catalog_controller.dart' '        products.assignAll(items);' @'
        products.assignAll(items);
        Get.find<CustomerCartController>().syncProducts(items);
'@

Edit-File 'lib/customer/screens/catalog/customer_catalog_screen.dart' "import '../../../core/widgets/shop_product_card.dart';" @'
import '../../../core/widgets/shop_product_card.dart';
import '../../../core/widgets/shop_button.dart';
import '../../controllers/customer_cart_controller.dart';
import '../cart/shop_cart_screen.dart';
import '../orders/shop_orders_screen.dart';
'@
Edit-File 'lib/customer/screens/catalog/customer_catalog_screen.dart' '        actions: [' @'
        actions: [
          IconButton(
            tooltip: 'My orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Get.to<void>(() => const ShopOrdersScreen()),
          ),
          Obx(() {
            final count = Get.find<CustomerCartController>().count;
            return IconButton(
              tooltip: 'View cart',
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              onPressed: () => Get.to<void>(() => const ShopCartScreen()),
            );
          }),
'@
Edit-File 'lib/customer/screens/catalog/customer_catalog_screen.dart' @'
                const Text('Cart and checkout are coming in the next feature.',
                    style: TextStyle(color: ShopColors.muted)),
'@ @'
                ShopButton(
                  label: product.stock > 0 ? 'Add to bag' : 'Out of stock',
                  icon: Icons.add_shopping_cart_outlined,
                  onPressed: product.stock <= 0
                      ? null
                      : () {
                          final message = Get.find<CustomerCartController>()
                              .addProduct(product);
                          if (message != null) {
                            Get.snackbar('Cannot add item', message);
                            return;
                          }
                          Get.back<void>();
                          Get.snackbar('Added to bag', product.name);
                        },
                ),
'@

Edit-File 'lib/admin/screens/products/admin_products_screen.dart' "import '../../../services/product_service.dart';" @'
import '../../../services/product_service.dart';
import '../orders/admin_orders_screen.dart';
'@
Edit-File 'lib/admin/screens/products/admin_products_screen.dart' '        actions: [' @'
        actions: [
          IconButton(
            tooltip: 'Manage orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Get.to<void>(() => const AdminOrdersScreen()),
          ),
'@

$ordersRules = @'
    match /orders/{orderId} {
      function validOrderRequest() {
        return request.resource.data.keys().hasOnly([
            'customerId', 'customerName', 'phone', 'shippingAddress',
            'items', 'subtotal', 'total', 'paymentMethod', 'status',
            'createdAt', 'updatedAt'
          ])
          && request.resource.data.keys().hasAll([
            'customerId', 'customerName', 'phone', 'shippingAddress',
            'items', 'subtotal', 'total', 'paymentMethod', 'status',
            'createdAt', 'updatedAt'
          ])
          && request.resource.data.customerId == request.auth.uid
          && request.resource.data.customerName is string
          && request.resource.data.customerName.size() >= 2
          && request.resource.data.phone is string
          && request.resource.data.phone.matches('^[0-9]{10}$')
          && request.resource.data.shippingAddress is string
          && request.resource.data.shippingAddress.size() >= 10
          && request.resource.data.items is list
          && request.resource.data.items.size() >= 1
          && request.resource.data.items.size() <= 10
          && request.resource.data.subtotal is int
          && request.resource.data.total is int
          && request.resource.data.subtotal == request.resource.data.total
          && request.resource.data.total > 0
          && request.resource.data.total <= 10000000
          && request.resource.data.paymentMethod == 'cash_on_delivery'
          && request.resource.data.status == 'pending'
          && request.resource.data.createdAt == request.time
          && request.resource.data.updatedAt == request.time;
      }

      allow get, list: if signedIn()
        && (isAdmin() || resource.data.customerId == request.auth.uid);
      allow create: if signedIn() && validOrderRequest();
      allow update: if isAdmin()
        && request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['status', 'updatedAt'])
        && request.resource.data.status in [
          'pending', 'confirmed', 'packed', 'shipped', 'delivered', 'cancelled'
        ]
        && request.resource.data.updatedAt == request.time;
      allow delete: if false;
    }

'@
Edit-File 'firestore.rules' '    match /{document=**} {' ($ordersRules + '    match /{document=**} {')

Write-Host "`nIntegration complete. Backups: $backup" -ForegroundColor Green
Write-Host 'Next: dart format lib; flutter analyze; flutter test test/cart'
Write-Host 'IMPORTANT: Publish the updated firestore.rules in Firebase Console before testing orders.' -ForegroundColor Yellow
