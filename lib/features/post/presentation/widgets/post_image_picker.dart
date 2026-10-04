import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostImagePicker extends StatelessWidget {
  const PostImagePicker({
    super.key,
    required this.images,
    required this.onChanged,
    this.enabled = true,
    this.maxImages = 5,
  });

  final List<XFile> images;
  final ValueChanged<List<XFile>> onChanged;
  final bool enabled;
  final int maxImages;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final selected = source == ImageSource.camera
          ? <XFile>[?await picker.pickImage(source: source, imageQuality: 85)]
          : await picker.pickMultiImage(imageQuality: 85);
      if (selected.isEmpty) return;

      final merged = [...images];
      for (final image in selected) {
        if (merged.length == maxImages) break;
        if (!merged.any((current) => current.path == image.path)) {
          merged.add(image);
        }
      }
      onChanged(List.unmodifiable(merged));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ảnh. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ảnh tài liệu (${images.length}/$maxImages)'),
        const SizedBox(height: 8),
        if (images.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var index = 0; index < images.length; index++)
                _ImagePreview(
                  image: images[index],
                  onRemove: enabled
                      ? () {
                          final updated = [...images]..removeAt(index);
                          onChanged(List.unmodifiable(updated));
                        }
                      : null,
                ),
            ],
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: enabled && images.length < maxImages
                  ? () => _pick(context, ImageSource.gallery)
                  : null,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Thư viện'),
            ),
            OutlinedButton.icon(
              onPressed: enabled && images.length < maxImages
                  ? () => _pick(context, ImageSource.camera)
                  : null,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Chụp ảnh'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});

  final XFile image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FutureBuilder<Uint8List>(
            future: image.readAsBytes(),
            builder: (context, snapshot) => SizedBox(
              width: 96,
              height: 96,
              child: snapshot.hasData
                  ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                  : const ColoredBox(
                      color: Color(0xFFE7ECF3),
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ),
          ),
        ),
        Positioned(
          right: -8,
          top: -8,
          child: IconButton.filled(
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }
}
