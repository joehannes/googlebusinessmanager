import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Image capture/selection with platform-aware cropping (GBP prefers 4:3)
/// and persistence of picked files into the app's documents directory so
/// staged catalog entries keep valid image paths.
class MediaService {
  MediaService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  bool get supportsCamera =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  bool get _supportsCropping =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<XFile?> pickImage({bool fromCamera = false}) async {
    final image = await _picker.pickImage(
      source: fromCamera && supportsCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (image == null) return null;
    return _cropIfPossible(image);
  }

  /// GBP bulk flows cap at 20 images per batch.
  Future<List<XFile>> pickMultipleImages({int limit = 20}) async {
    final images = await _picker.pickMultiImage(
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    return images.take(limit).toList();
  }

  Future<XFile> _cropIfPossible(XFile image) async {
    if (!_supportsCropping) return image;
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust image (4:3 recommended)',
            toolbarColor: Colors.indigo,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Adjust image'),
        ],
      );
      return cropped == null ? image : XFile(cropped.path);
    } catch (_) {
      return image;
    }
  }

  /// Copies a picked image out of the platform cache into permanent app
  /// storage; returns the durable path (or null on web, where paths are
  /// blob URLs kept as-is).
  Future<String> persistImage(XFile image) async {
    if (kIsWeb) return image.path;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'gbp_images'));
    await dir.create(recursive: true);
    final name = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
    final target = p.join(dir.path, name);
    await File(image.path).copy(target);
    return target;
  }
}

final mediaServiceProvider = Provider<MediaService>((ref) => MediaService());
