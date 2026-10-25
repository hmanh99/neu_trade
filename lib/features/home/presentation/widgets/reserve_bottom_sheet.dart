import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import '../../domain/entities/home_post_entity.dart';
import '../../../../shared/wigdets/formatters.dart';

class ReserveBottomSheet extends StatefulWidget {
  const ReserveBottomSheet({
    super.key,
    required this.post,
    required this.onConfirm,
    this.isLoading = false,
  });

  final HomePostEntity post;
  final void Function(String note) onConfirm;
  final bool isLoading;

  static Future<void> show({
    required BuildContext context,
    required HomePostEntity post,
    required void Function(String note) onConfirm,
    bool isLoading = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorConstants.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReserveBottomSheet(
        post: post,
        onConfirm: onConfirm,
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<ReserveBottomSheet> createState() => _ReserveBottomSheetState();
}

class _ReserveBottomSheetState extends State<ReserveBottomSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorConstants.greyShade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Xác nhận đặt trước',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.greyShade900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
                color: ColorConstants.greyShade600,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary item box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorConstants.greyShade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColorConstants.borderLightColor),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: ColorConstants.primaryLightBg,
                    child: widget.post.imageUrls.isNotEmpty
                        ? Image.network(
                            widget.post.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.menu_book_rounded,
                              size: 24,
                              color: ColorConstants.primaryColor,
                            ),
                          )
                        : const Icon(
                            Icons.menu_book_rounded,
                            size: 24,
                            color: ColorConstants.primaryColor,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(widget.post.document.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Location note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: ColorConstants.primaryLightBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConstants.blueShade100),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.place_rounded,
                  size: 18,
                  color: ColorConstants.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Địa điểm gặp nhận sách: ${widget.post.address.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Note input
          const Text(
            'Lời nhắn cho người bán (không bắt buộc):',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'VD: Mình có thể gặp bạn vào giờ ra chơi tiết 2...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: ColorConstants.greyShade400,
              ),
              filled: true,
              fillColor: ColorConstants.greyShade50,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorConstants.borderLightColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorConstants.borderLightColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorConstants.primaryColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Reminder note
          const Text(
            'Lưu ý: Bạn và người bán sẽ gặp trực tiếp trong khuôn viên trường NEU để kiểm tra tài liệu và thanh toán.',
            style: TextStyle(
              fontSize: 11.5,
              color: ColorConstants.textSecondaryColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),

          // Confirm button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: ColorConstants.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      widget.onConfirm(_noteController.text.trim());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Xác nhận đặt trước',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
