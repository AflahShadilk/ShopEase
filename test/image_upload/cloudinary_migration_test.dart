import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/services/product_image_service.dart';

void main() {
  test('Cloudinary identifiers reject empty, URL and spaces', () {
    expect(CloudinaryConfig.validIdentifier('demo-shop'), isTrue);
    expect(CloudinaryConfig.validIdentifier('preset_123'), isTrue);
    expect(CloudinaryConfig.validIdentifier(''), isFalse);
    expect(CloudinaryConfig.validIdentifier('https://example.com'), isFalse);
    expect(CloudinaryConfig.validIdentifier('my preset'), isFalse);
  });

  test('Cloudinary response returns secure image URL and public ID', () {
    final image = CloudinaryUploadResponse.fromMap({
      'public_id': 'shopease/products/abc123',
      'secure_url':
          'https://res.cloudinary.com/demo/image/upload/v1/abc123.jpg',
      'resource_type': 'image',
    });
    expect(image.publicId, 'shopease/products/abc123');
    expect(image.url, startsWith('https://res.cloudinary.com/'));
  });

  test('Cloudinary response rejects missing or non-image data', () {
    expect(() => CloudinaryUploadResponse.fromMap({}), throwsFormatException);
    expect(
      () => CloudinaryUploadResponse.fromMap({
        'public_id': 'abc',
        'secure_url': 'https://example.com/abc.jpg',
        'resource_type': 'image',
      }),
      throwsFormatException,
    );
    expect(
      () => CloudinaryUploadResponse.fromMap({
        'public_id': 'abc',
        'secure_url': 'https://res.cloudinary.com/demo/video/upload/abc.mp4',
        'resource_type': 'video',
      }),
      throwsFormatException,
    );
  });

  test('Existing PNG file validation remains intact', () {
    final selection = ProductImageSelection.fromBytes(
      filename: 'poster.png',
      bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0]),
    );
    expect(selection.contentType, 'image/png');
  });
}
