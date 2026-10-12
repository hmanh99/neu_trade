import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import '../../domain/entities/home_post_entity.dart';
import 'home_formatters.dart';

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
              color: ColorConstants.greyShade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: ColorConstants.greyShade200,
                    child: widget.post.imageUrls.isNotEmpty
                        ? Image.network(
                            widget.post.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.menu_book_rounded,
                              size: 24,
                              color: ColorConstants.greyShade400,
                            ),
                          )
                        : const Icon(
                            Icons.menu_book_rounded,
                            size: 24,
                            color: ColorConstants.greyShade400,
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
                          color: ColorConstants.greyShade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        HomeFormatters.formatCurrency(widget.post.document.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
              color: ColorConstants.blue.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConstants.blue.withAlpha(40)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: ColorConstants.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Địa điểm gặp nhận sách: ${widget.post.address.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
              color: ColorConstants.greyShade800,
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
                borderSide: const BorderSide(color: ColorConstants.greyShade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorConstants.greyShade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorConstants.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Reminder note
          const Text(
            'Lưu ý: Bạn và người bán sẽ gặp trực tiếp trong khuôn viên trường NEU để kiểm tra tài liệu và thanh toán.',
            style: TextStyle(
              fontSize: 11,
              color: ColorConstants.greyShade600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      widget.onConfirm(_noteController.text.trim());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: ColorConstants.white,
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
                            AlwaysStoppedAnimation<Color>(ColorConstants.white),
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
