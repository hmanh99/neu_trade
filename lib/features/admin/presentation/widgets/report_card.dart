import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';
import 'package:neu_trade/features/admin/domain/entities/report_status.dart';

import '../../../../shared/wigdets/formatters.dart';

class ReportCard extends StatelessWidget {
  final AdminReportEntity report;
  final bool isResolving;
  final VoidCallback onResolveTap;

  const ReportCard({
    super.key,
    required this.report,
    required this.isResolving,
    required this.onResolveTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = report.status == ReportStatus.ChoXuLy;
    final firstImage =
        report.postImageUrls.isNotEmpty ? report.postImageUrls.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status badge + Report time
            Row(
              children: [
                _buildStatusBadge(report.status),
                const Spacer(),
                Text(
                  Formatters.formatRelativeTime(report.createdAt),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reporter & Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.report_problem_outlined,
                  size: 20,
                  color: ColorConstants.errorColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reason,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Người báo cáo: ${report.reporterName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (report.description != null &&
                report.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorConstants.greyShade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  report.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorConstants.textPrimaryColor,
                    height: 1.35,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Associated Post Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorConstants.greyShade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConstants.greyShade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: ColorConstants.greyShade200,
                      child: firstImage != null
                          ? Image.network(
                              firstImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.menu_book_rounded,
                                color: ColorConstants.greyShade400,
                                size: 24,
                              ),
                            )
                          : const Icon(
                              Icons.menu_book_rounded,
                              color: ColorConstants.greyShade400,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.postTitle ?? 'Bài đăng #${report.postId}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ColorConstants.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (report.postAuthorName != null) ...[
                              Text(
                                'Đăng bởi: ${report.postAuthorName}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: ColorConstants.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (report.postStatus != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConstants.greyShade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  report.postStatus!.label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.greyShade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isPending) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: ColorConstants.dividerColor),
              const SizedBox(height: 12),
              if (isResolving)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onResolveTap,
                    icon: const Icon(Icons.gavel_rounded, size: 18),
                    label: const Text(
                      'Xử lý báo cáo',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case ReportStatus.ChoXuLy:
        bg = ColorConstants.orangeShade50;
        fg = const Color(0xFFD97706);
        icon = Icons.schedule_rounded;
        break;
      case ReportStatus.DaXuLy:
        bg = ColorConstants.greenShade50;
        fg = const Color(0xFF16A34A);
        icon = Icons.check_circle_outline_rounded;
        break;
      case ReportStatus.BacBo:
        bg = ColorConstants.greyShade100;
        fg = ColorConstants.greyShade600;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
