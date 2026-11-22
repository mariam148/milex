import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Photos remain in memory for this session; nothing is uploaded.
class ProfilePhotoPicker {
  static final shared = ProfilePhotoPicker();
  final _picker = ImagePicker();
  Uint8List? recoveredPhoto;

  Future<Uint8List?> pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    return file?.readAsBytes();
  }

  // Android can kill the activity while the external camera/picker is open.
  Future<void> recover() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final result = await _picker.retrieveLostData();
      if (result.files?.isNotEmpty ?? false) {
        recoveredPhoto = await result.files!.first.readAsBytes();
      }
    } catch (_) {
      // Recovery must not prevent launching. A fresh photo can be selected.
      recoveredPhoto = null;
    }
  }
}
