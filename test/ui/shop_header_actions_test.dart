import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/widgets/shop_header_actions.dart';

void main() {
  testWidgets('Logout Cancel closes dialog without signing out',
      (tester) async {
    var signOutCalls = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(actions: [
          ShopLogoutAction(onLogout: () async {
            signOutCalls++;
          }),
        ]),
      ),
    ));

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out of ShopEase?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(signOutCalls, 0);
    expect(find.text('Log out of ShopEase?'), findsNothing);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    // FilledButton.icon is rendered as an internal subtype of FilledButton.
    // Tap the visible dialog label rather than matching an internal button type.
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(signOutCalls, 1);
  });

  for (final width in <double>[320, 375, 600]) {
    testWidgets('Admin header fits ${width.toInt()}px screen', (tester) async {
      var customerCalls = 0;
      await tester.binding.setSurfaceSize(Size(width, 700));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('ShopEase'),
            actions: [
              ShopAdminHeaderActions(
                onCustomers: () => customerCalls++,
                onOrders: () {},
                onLogout: () async {},
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Dashboard actions'), findsOneWidget);
      await tester.tap(find.byTooltip('Dashboard actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();
      expect(customerCalls, 1);
    });
  }

  testWidgets('Compact menu log out respects Cancel', (tester) async {
    var signOutCalls = 0;
    await tester.binding.setSurfaceSize(const Size(375, 700));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(actions: [
          ShopAdminHeaderActions(
            onCustomers: () {},
            onOrders: () {},
            onLogout: () async {
              signOutCalls++;
            },
          ),
        ]),
      ),
    ));
    await tester.tap(find.byTooltip('Dashboard actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out of ShopEase?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(signOutCalls, 0);
  });

  testWidgets('Desktop admin navigation shows labeled actions', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(actions: [
          ShopAdminHeaderActions(
            onCustomers: () {},
            onOrders: () {},
            onLogout: () async {},
          ),
        ]),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });
}
