import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

Future<bool> showPostHistoryDeleteDialog(
  BuildContext context, {
  required String postTitle,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: ColorConstants.errorColor,
            size: 24,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Xoá bài đăng?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'Bạn có chắc chắn muốn xoá bài đăng "$postTitle"? Hành động này sẽ xoá vĩnh viễn bài đăng và hình ảnh đính kèm.',
        style: const TextStyle(
          fontSize: 14,
          color: ColorConstants.textSecondaryColor,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text(
            'Huỷ',
            style: TextStyle(
              color: ColorConstants.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: ColorConstants.errorColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Xoá bài',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> showPostHistoryReapprovalWarningDialog(
  BuildContext context,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: ColorConstants.warningColor,
            size: 24,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chuyển về chờ duyệt',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
      content: const Text(
        'Bài đăng đang hiển thị công khai. Sau khi lưu chỉnh sửa, bài đăng sẽ tạm ẩn khỏi trang chủ và chuyển về trạng thái "Chờ duyệt" để quản trị viên kiểm duyệt lại.',
        style: TextStyle(
          fontSize: 14,
          color: ColorConstants.textSecondaryColor,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text(
            'Huỷ',
            style: TextStyle(
              color: ColorConstants.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: ColorConstants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Lưu & chờ duyệt lại',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
