import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hình ảnh tài liệu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ColorConstants.primaryLightBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${images.length}/$maxImages ảnh',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
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
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled && images.length < maxImages
                    ? () => _pick(context, ImageSource.gallery)
                    : null,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Thư viện'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled && images.length < maxImages
                    ? () => _pick(context, ImageSource.camera)
                    : null,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Chụp ảnh'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorConstants.borderLightColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FutureBuilder<Uint8List>(
              future: image.readAsBytes(),
              builder: (context, snapshot) => SizedBox(
                width: 90,
                height: 90,
                child: snapshot.hasData
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : const ColoredBox(
                        color: ColorConstants.greyShade100,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            right: -6,
            top: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: ColorConstants.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
