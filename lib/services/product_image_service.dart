import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProductImageSelection {
  ProductImageSelection._({
    required this.filename,
    required this.bytes,
    required this.contentType,
    required this.extension,
  });

  static const int maxBytes = 5 * 1024 * 1024;
  final String filename;
  final Uint8List bytes;
  final String contentType;
  final String extension;

  factory ProductImageSelection.fromBytes({
    required String filename,
    required Uint8List bytes,
  }) {
    final extension = filename.split('.').last.toLowerCase();
    final type = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => null,
    };
    if (type == null) {
      throw const FormatException('Select a JPG, PNG or WebP image.');
    }
    if (bytes.isEmpty || bytes.length >= maxBytes) {
      throw const FormatException('Image must be smaller than 5 MB.');
    }
    if (!_hasImageSignature(type, bytes)) {
      throw const FormatException('Image file does not match its format.');
    }
    return ProductImageSelection._(
      filename: filename,
      bytes: bytes,
      contentType: type,
      extension: extension == 'jpeg' ? 'jpg' : extension,
    );
  }

  static bool _hasImageSignature(String type, Uint8List data) {
    if (type == 'image/jpeg') {
      return data.length >= 3 &&
          data[0] == 0xff &&
          data[1] == 0xd8 &&
          data[2] == 0xff;
    }
    if (type == 'image/png') {
      const signature = [137, 80, 78, 71, 13, 10, 26, 10];
      if (data.length < signature.length) {
        return false;
      }
      for (var i = 0; i < signature.length; i++) {
        if (data[i] != signature[i]) {
          return false;
        }
      }
      return true;
    }
    return data.length >= 12 &&
        data[0] == 82 &&
        data[1] == 73 &&
        data[2] == 70 &&
        data[3] == 70 &&
        data[8] == 87 &&
        data[9] == 69 &&
        data[10] == 66 &&
        data[11] == 80;
  }
}

class UploadedProductImage {
  const UploadedProductImage({required this.path, required this.url});
  final String path;
  final String url;
}

class ProductImageService {
  ProductImageService({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  Future<ProductImageSelection?> pick() async {
    final chosen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1400,
      maxHeight: 1400,
      imageQuality: 82,
    );
    if (chosen == null) {
      return null;
    }
    return ProductImageSelection.fromBytes(
      filename: chosen.name,
      bytes: await chosen.readAsBytes(),
    );
  }

  Future<UploadedProductImage> upload(ProductImageSelection selection) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please sign in as admin again.');
    }
    final name = DateTime.now().microsecondsSinceEpoch;
    final path = 'product_images/$uid/$name.${selection.extension}';
    final reference = _storage.ref().child(path);
    await reference.putData(
      selection.bytes,
      SettableMetadata(contentType: selection.contentType),
    );
    return UploadedProductImage(
      path: path,
      url: await reference.getDownloadURL(),
    );
  }

  Future<void> deleteUploaded(String path) =>
      _storage.ref().child(path).delete();
}
