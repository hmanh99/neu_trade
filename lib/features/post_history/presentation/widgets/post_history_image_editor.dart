import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

import '../../domain/entities/post_history_image_input.dart';

class PostHistoryImageEditor extends StatelessWidget {
  const PostHistoryImageEditor({
    super.key,
    required this.images,
    required this.onChanged,
    this.enabled = true,
    this.maxImages = maxPostHistoryImages,
  });

  final List<PostHistoryImageInput> images;
  final ValueChanged<List<PostHistoryImageInput>> onChanged;
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
      for (final file in selected) {
        if (merged.length >= maxImages) break;
        final alreadyPicked = merged.any(
          (item) =>
              item is NewPostHistoryImage &&
              item.localPath != null &&
              item.localPath == file.path,
        );
        if (alreadyPicked) continue;

        final parsed = await _readImage(file);
        merged.add(parsed);
      }
      onChanged(List.unmodifiable(merged));
    } on FormatException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message.toString()),
          backgroundColor: ColorConstants.snackBarFailedColor,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chọn ảnh. Vui lòng thử lại.'),
          backgroundColor: ColorConstants.snackBarFailedColor,
        ),
      );
    }
  }

  Future<NewPostHistoryImage> _readImage(XFile image) async {
    var extension = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : '';
    if (extension == 'jpeg') extension = 'jpg';
    const contentTypes = {
      'jpg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'heic': 'image/heic',
      'heif': 'image/heif',
    };
    final contentType = contentTypes[extension];
    if (contentType == null) {
      throw const FormatException(
        'Ảnh phải có định dạng JPG, PNG, WEBP, HEIC hoặc HEIF.',
      );
    }
    return NewPostHistoryImage(
      bytes: await image.readAsBytes(),
      extension: extension,
      contentType: contentType,
      localPath: image.path,
    );
  }

  void _moveLeft(int index) {
    if (index <= 0) return;
    final updated = [...images];
    final item = updated.removeAt(index);
    updated.insert(index - 1, item);
    onChanged(List.unmodifiable(updated));
  }

  void _moveRight(int index) {
    if (index >= images.length - 1) return;
    final updated = [...images];
    final item = updated.removeAt(index);
    updated.insert(index + 1, item);
    onChanged(List.unmodifiable(updated));
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
        const SizedBox(height: 6),
        const Text(
          'Ảnh đầu tiên sẽ làm ảnh bìa. Dùng mũi tên để đổi thứ tự ảnh.',
          style: TextStyle(
            fontSize: 12,
            color: ColorConstants.textSecondaryColor,
          ),
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
                  _EditableImageTile(
                    item: images[index],
                    isCover: index == 0,
                    canMoveLeft: enabled && index > 0,
                    canMoveRight: enabled && index < images.length - 1,
                    onMoveLeft: () => _moveLeft(index),
                    onMoveRight: () => _moveRight(index),
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
                label: const Text('Thêm từ thư viện'),
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

class _EditableImageTile extends StatelessWidget {
  const _EditableImageTile({
    required this.item,
    required this.isCover,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRemove,
  });

  final PostHistoryImageInput item;
  final bool isCover;
  final bool canMoveLeft;
  final bool canMoveRight;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 112,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCover
                  ? ColorConstants.primaryColor
                  : ColorConstants.borderLightColor,
              width: isCover ? 1.5 : 1,
            ),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: switch (item) {
                      ExistingPostHistoryImage(:final url) => Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: ColorConstants.greyShade100,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: ColorConstants.greyShade400,
                          ),
                        ),
                      ),
                      NewPostHistoryImage(:final bytes) => Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                      ),
                    },
                  ),
                ),
              ),
              Container(
                height: 24,
                decoration: const BoxDecoration(
                  color: ColorConstants.greyShade50,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(13),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: canMoveLeft ? onMoveLeft : null,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: canMoveLeft
                            ? ColorConstants.textPrimaryColor
                            : ColorConstants.greyShade300,
                      ),
                    ),
                    if (isCover)
                      const Text(
                        'Bìa',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: ColorConstants.primaryColor,
                        ),
                      )
                    else
                      const SizedBox(width: 16),
                    InkWell(
                      onTap: canMoveRight ? onMoveRight : null,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: canMoveRight
                            ? ColorConstants.textPrimaryColor
                            : ColorConstants.greyShade300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
