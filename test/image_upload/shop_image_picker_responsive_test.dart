import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/widgets/shop_image_picker_field.dart';

void main() {
  for (final width in <double>[320, 375, 768, 1280]) {
    for (final scale in <double>[1.0, 1.3]) {
      testWidgets('Photo picker at ${width.toInt()}px, text $scale',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() async => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: ShopImagePickerField(
                onPick: () {},
                onClear: () {},
              ),
            ),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Choose image'), findsOneWidget);
      });
    }
  }
}
