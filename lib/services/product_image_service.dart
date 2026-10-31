import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Values are supplied at build/run time; never include a Cloudinary API secret.
class CloudinaryConfig {
  static const cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const uploadPreset =
      String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');

  static bool validIdentifier(String value) =>
      RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value);

  static bool get isConfigured =>
      validIdentifier(cloudName) && validIdentifier(uploadPreset);

  static Uri get uploadUri =>
      Uri.https('api.cloudinary.com', '/v1_1/$cloudName/image/upload');
}

/// Validates a picked image before sending any bytes to Cloudinary.
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
      if (data.length < signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (data[i] != signature[i]) return false;
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

/// `path` holds Cloudinary's public_id, not a Firebase Storage object path.
class UploadedProductImage {
  const UploadedProductImage({required this.path, required this.url});
  final String path;
  final String url;
}

class CloudinaryUploadResponse {
  const CloudinaryUploadResponse({required this.publicId, required this.url});
  final String publicId;
  final String url;

  factory CloudinaryUploadResponse.fromMap(Map<String, dynamic> data) {
    final url = data['secure_url'];
    final publicId = data['public_id'];
    final resourceType = data['resource_type'];
    if (url is! String ||
        !url.startsWith('https://') ||
        Uri.tryParse(url)?.host != 'res.cloudinary.com' ||
        publicId is! String ||
        publicId.isEmpty ||
        resourceType != 'image') {
      throw const FormatException('Unexpected Cloudinary image response.');
    }
    return CloudinaryUploadResponse(publicId: publicId, url: url);
  }
}

class ProductImageService {
  ProductImageService({
    FirebaseAuth? auth,
    ImagePicker? picker,
    http.Client? client,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _picker = picker ?? ImagePicker(),
        _client = client;

  final FirebaseAuth _auth;
  final ImagePicker _picker;
  final http.Client? _client;

  Future<ProductImageSelection?> pick() async {
    final chosen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1400,
      maxHeight: 1400,
      imageQuality: 82,
    );
    if (chosen == null) return null;
    return ProductImageSelection.fromBytes(
      filename: chosen.name,
      bytes: await chosen.readAsBytes(),
    );
  }

  /// Unsigned direct upload for the machine test. The Cloudinary preset is
  /// public to anyone inspecting the app and is NOT an admin authorization rule.
  Future<UploadedProductImage> upload(ProductImageSelection selection) async {
    if (_auth.currentUser == null) {
      throw StateError('Admin session expired. Sign in again.');
    }
    if (!CloudinaryConfig.isConfigured) {
      throw StateError(
        'Cloudinary is not configured. Supply CLOUDINARY_CLOUD_NAME and '
        'CLOUDINARY_UPLOAD_PRESET with --dart-define.',
      );
    }

    final client = _client ?? http.Client();
    try {
      final request = http.MultipartRequest('POST', CloudinaryConfig.uploadUri)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          selection.bytes,
          filename: selection.filename,
        ));
      debugPrint('[Cloudinary] Starting image upload');
      final streamed = await client.send(request).timeout(
            const Duration(seconds: 55),
          );
      final response = await http.Response.fromStream(streamed).timeout(
        const Duration(seconds: 20),
      );
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        throw StateError(
            'Cloudinary returned invalid JSON (HTTP ${response.statusCode}).');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = data['error'];
        final detail = error is Map ? error['message']?.toString() : null;
        throw StateError(
            'Cloudinary upload failed (HTTP ${response.statusCode}): '
            '${detail ?? 'Check cloud name and unsigned upload preset.'}');
      }
      final uploaded = CloudinaryUploadResponse.fromMap(data);
      debugPrint('[Cloudinary] Upload succeeded: ${uploaded.publicId}');
      return UploadedProductImage(path: uploaded.publicId, url: uploaded.url);
    } on TimeoutException {
      throw StateError(
        'Cloudinary upload timed out. Check your connection and preset. '
        'The upload may still have completed remotely.',
      );
    } finally {
      if (_client == null) client.close();
    }
  }
}
