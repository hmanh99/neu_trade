import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

import '../../domain/entities/post_history_status.dart';

class PostHistoryEmptyView extends StatelessWidget {
  const PostHistoryEmptyView({
    super.key,
    required this.selectedStatus,
    required this.onClearFilter,
    required this.onUploadTap,
  });

  final PostHistoryStatus? selectedStatus;
  final VoidCallback onClearFilter;
  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    final isFiltered = selectedStatus != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ColorConstants.primaryLightBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.history_edu_rounded,
                size: 34,
                color: ColorConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'Không có bài đăng ở trạng thái "${selectedStatus!.label}"'
                  : 'Bạn chưa có bài đăng nào',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Hãy thử chuyển sang bộ lọc khác để xem toàn bộ lịch sử bài đăng của bạn.'
                  : 'Chia sẻ giáo trình và tài liệu học tập không còn dùng tới cho các bạn sinh viên NEU.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: ColorConstants.textSecondaryColor,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: onClearFilter,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Xem tất cả bài đăng'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorConstants.primaryColor,
                  side: const BorderSide(color: ColorConstants.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: onUploadTap,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Đăng bài ngay'),
                style: FilledButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
