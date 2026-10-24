import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';

class ResolveReportSheet extends StatelessWidget {
  final AdminReportEntity report;
  final ValueChanged<String> onResolve;

  const ResolveReportSheet({
    super.key,
    required this.report,
    required this.onResolve,
  });

  static Future<void> show({
    required BuildContext context,
    required AdminReportEntity report,
    required ValueChanged<String> onResolve,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResolveReportSheet(
        report: report,
        onResolve: onResolve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ColorConstants.greyShade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Xử lý báo cáo vi phạm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ColorConstants.textPrimaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Báo cáo cho bài viết: "${report.postTitle ?? 'Bài đăng #${report.postId}'}"',
            style: const TextStyle(
              fontSize: 13.5,
              color: ColorConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorConstants.greyShade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorConstants.borderLightColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: ColorConstants.errorColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lý do: ${report.reason}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                if (report.description != null &&
                    report.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Chi tiết: ${report.description}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Chọn kết quả xử lý:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // Option 1: DaXuLy (Đã xử lý)
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              onResolve('DaXuLy');
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorConstants.greenShade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorConstants.greenShade100),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF16A34A),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã xử lý (Vi phạm hợp lệ)',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Xác nhận nội dung báo cáo là chính xác.',
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorConstants.greyShade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF15803D),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Option 2: BacBo (Bác bỏ)
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              onResolve('BacBo');
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorConstants.greyShade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorConstants.greyShade200),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: ColorConstants.greyShade600,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bác bỏ báo cáo',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: ColorConstants.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Báo cáo không đúng hoặc không có vi phạm.',
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: ColorConstants.greyShade400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
