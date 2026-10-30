import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/services/product_image_service.dart';

void main() {
  test('JPG image signature, metadata, and extension are accepted', () {
    final image = ProductImageSelection.fromBytes(
      filename: 'camera.JPEG',
      bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0x00]),
    );
    expect(image.extension, 'jpg');
    expect(image.contentType, 'image/jpeg');
  });

  test('PNG and WebP have recognized file signatures', () {
    final png = ProductImageSelection.fromBytes(
      filename: 'image.png',
      bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
    );
    final webp = ProductImageSelection.fromBytes(
      filename: 'image.webp',
      bytes: Uint8List.fromList([
        82,
        73,
        70,
        70,
        0,
        0,
        0,
        0,
        87,
        69,
        66,
        80,
      ]),
    );
    expect(png.contentType, 'image/png');
    expect(webp.contentType, 'image/webp');
  });

  test('unsupported extension and spoofed image are rejected', () {
    expect(
      () => ProductImageSelection.fromBytes(
        filename: 'a.pdf',
        bytes: Uint8List.fromList([37, 80, 68, 70]),
      ),
      throwsFormatException,
    );
    expect(
      () => ProductImageSelection.fromBytes(
        filename: 'a.jpg',
        bytes: Uint8List.fromList([0, 1, 2, 3]),
      ),
      throwsFormatException,
    );
  });

  test('empty and oversized images are rejected', () {
    expect(
      () => ProductImageSelection.fromBytes(
        filename: 'a.jpg',
        bytes: Uint8List(0),
      ),
      throwsFormatException,
    );
    final big = Uint8List(ProductImageSelection.maxBytes);
    big.setRange(0, 3, [0xff, 0xd8, 0xff]);
    expect(
      () => ProductImageSelection.fromBytes(filename: 'big.jpg', bytes: big),
      throwsFormatException,
    );
  });
}
