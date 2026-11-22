import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/profile_photo_picker.dart';

/// Shared camera/gallery selection, validation and replacement for session photos.
class OnboardingPhotoInput extends StatefulWidget {
  const OnboardingPhotoInput({
    super.key,
    required this.label,
    required this.bytes,
    required this.onChanged,
    this.picker,
    this.profile = false,
  });
  final String label;
  final Uint8List? bytes;
  final ValueChanged<Uint8List> onChanged;
  final ProfilePhotoPicker? picker;
  final bool profile;
  @override
  State<OnboardingPhotoInput> createState() => _OnboardingPhotoInputState();
}

class _OnboardingPhotoInputState extends State<OnboardingPhotoInput> {
  bool _busy = false;
  bool _sheetOpen = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final picker = widget.picker ?? ProfilePhotoPicker.shared;
    final recovered = widget.profile ? picker.recoveredPhoto : null;
    if (recovered != null && widget.bytes == null) {
      picker.recoveredPhoto = null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        setState(() => _busy = true);
        try {
          await _acceptPhoto(recovered);
        } catch (_) {
          if (mounted) {
            setState(() => _error = 'Please select your photo again.');
          }
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      });
    }
  }

  Future<void> _acceptPhoto(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 512);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
    if (!mounted) return;
    widget.onChanged(bytes);
    setState(() => _error = null);
  }

  Future<void> _choose() async {
    if (_busy || _sheetOpen) return;
    _sheetOpen = true;
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: const Color(0xFF171322),
        showDragHandle: true,
        useSafeArea: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add a Photo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                for (final entry in [
                  (
                    ImageSource.camera,
                    Icons.camera_alt_outlined,
                    'Take a Photo',
                  ),
                  (
                    ImageSource.gallery,
                    Icons.photo_library_outlined,
                    'Upload from Library',
                  ),
                ])
                  Card(
                    color: const Color(0xFF242031),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Icon(entry.$2, color: const Color(0xFF6947FF)),
                      title: Text(entry.$3),
                      onTap: () => Navigator.pop(context, entry.$1),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );
      if (!mounted || source == null) return;
      setState(() => _busy = true);
      final bytes = await (widget.picker ?? ProfilePhotoPicker.shared).pick(
        source,
      );
      if (!mounted || bytes == null) return;
      await _acceptPhoto(bytes);
    } on PlatformException catch (error) {
      if (mounted) {
        setState(
          () => _error =
              error.code.contains('denied') || error.code.contains('restricted')
              ? 'Photo access is unavailable. Allow access in Settings or choose another source.'
              : 'Could not open the photo. Please try another source.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not read that image. Please try another photo.',
        );
      }
    } finally {
      _sheetOpen = false;
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.bytes == null
        ? Icon(
            widget.profile
                ? Icons.person_outline_rounded
                : Icons.file_upload_outlined,
            size: widget.profile ? 92 : 36,
            color: const Color(0xFF777183),
          )
        : Image.memory(
            widget.bytes!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, error, stack) =>
                const Icon(Icons.broken_image_outlined),
          );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.profile) ...[
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Semantics(
                    label: widget.bytes == null
                        ? 'No profile photo selected'
                        : 'Selected profile photo',
                    image: true,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF191620),
                        border: Border.all(color: const Color(0xFF393342)),
                      ),
                      child: ClipOval(child: preview),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 4,
                  child: IconButton.filled(
                    tooltip: 'Add a profile photo',
                    onPressed: _busy ? null : _choose,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF6947FF),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: _busy ? null : _choose,
            child: const Text('Add a Photo'),
          ),
        ] else
          Semantics(
            label: '${widget.label} license photo',
            child: InkWell(
              onTap: _busy ? null : _choose,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF15131D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF393342)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 96,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: preview,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.label, textAlign: TextAlign.center),
                    const Text(
                      'Tap to replace / upload',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFFFFB4AB)),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
