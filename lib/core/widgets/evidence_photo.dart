import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'ui_kit.dart';

/// Capture / attach a polling-unit sheet photo for later supervisor verification.
class EvidenceCaptureCard extends StatelessWidget {
  const EvidenceCaptureCard({
    super.key,
    required this.photoPath,
    required this.onChanged,
    this.title = 'Result sheet evidence',
    this.helper =
        'Photograph the official result sheet at this polling unit so supervisors can verify the figures you enter.',
    this.required = true,
  });

  final String? photoPath;
  final ValueChanged<String?> onChanged;
  final String title;
  final String helper;
  final bool required;

  bool get _hasPhoto => photoPath != null && photoPath!.trim().isNotEmpty;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (file != null) onChanged(file.path);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Camera unavailable — demo evidence stub attached.'
                : 'Gallery unavailable — demo evidence stub attached.',
          ),
        ),
      );
      onChanged(
        source == ImageSource.camera
            ? 'stub://result-sheet-camera.jpg'
            : 'stub://result-sheet-gallery.jpg',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: required ? '$title *' : title,
      icon: Icons.document_scanner_outlined,
      accent: ApcColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            helper,
            style: const TextStyle(
              fontSize: 13,
              color: ApcColors.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (_hasPhoto) ...[
            EvidencePhotoPreview(path: photoPath!, height: 180),
            const SizedBox(height: 10),
            Text(
              photoPath!.startsWith('stub://')
                  ? 'Demo evidence attached (device capture unavailable).'
                  : 'Sheet photo attached — supervisors will review this against your figures.',
              style: const TextStyle(
                fontSize: 12,
                color: ApcColors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _pick(context, ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: Text(
                    _hasPhoto ? 'Retake' : 'Camera',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(
                    _hasPhoto ? 'Replace' : 'Gallery',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          if (_hasPhoto) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => onChanged(null),
              child: const Text('Remove photo'),
            ),
          ],
        ],
      ),
    );
  }
}

class EvidencePhotoPreview extends StatelessWidget {
  const EvidencePhotoPreview({
    super.key,
    required this.path,
    this.height = 160,
    this.label = 'Result sheet photo',
  });

  final String path;
  final double height;
  final String label;

  bool get _isStub => path.startsWith('stub://');

  void _openFull(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(label, style: const TextStyle(fontSize: 16)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: _isStub
                    ? _StubEvidence(height: 320, label: label)
                    : Image.file(
                        File(path),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _StubEvidence(
                          height: 320,
                          label: 'Could not open photo',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ApcColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openFull(context),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isStub)
                _StubEvidence(height: height, label: label)
              else
                Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _StubEvidence(height: height, label: 'Photo missing'),
                ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StubEvidence extends StatelessWidget {
  const _StubEvidence({required this.height, required this.label});
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      color: ApcColors.blueSoft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 42,
            color: ApcColors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: ApcColors.blue,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Demo evidence placeholder',
            style: TextStyle(fontSize: 12, color: ApcColors.muted),
          ),
        ],
      ),
    );
  }
}
