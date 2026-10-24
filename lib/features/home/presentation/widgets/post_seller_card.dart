import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/services/profile_services.dart';
import '../../domain/entities/address.dart';
import '../../../../shared/home_formatters.dart';

class PostSellerCard extends StatelessWidget {
  const PostSellerCard({
    super.key,
    required this.authorName,
    required this.createdAt,
    required this.address,
    this.authorId,
    this.onContactTap,
  });

  final String authorName;
  final DateTime createdAt;
  final Address address;
  final String? authorId;
  final VoidCallback? onContactTap;

  @override
  Widget build(BuildContext context) {
    final initial = authorName.trim().isNotEmpty
        ? authorName.trim()[0].toUpperCase()
        : 'S';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: ColorConstants.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstants.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            authorName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ColorConstants.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.greenShade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 11,
                                color: ColorConstants.greenShade600,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Sinh viên NEU',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConstants.greenShade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đăng ${HomeFormatters.formatRelativeTime(createdAt)} · ${address.label}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onContactTap != null)
                IconButton.filledTonal(
                  onPressed: onContactTap,
                  style: IconButton.styleFrom(
                    backgroundColor: ColorConstants.primaryLightBg,
                    foregroundColor: ColorConstants.primaryColor,
                  ),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                  ),
                  tooltip: 'Nhắn tin người bán',
                ),
            ],
          ),

          // Seller Stats (Rating and Cancel Count)
          if (authorId != null && authorId!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ColorConstants.greyShade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorConstants.borderLightColor),
              ),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: ProfileServices().getUserPublicStats(userId: authorId!),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final rating = data?['diem_trung_binh']?.toString() ?? '5.0';
                  final count = data?['tong_danh_gia']?.toString() ?? '0';
                  final cancelCount =
                      (data?['so_lan_huy_don'] as num?)?.toInt() ?? 0;
                  final isHighCancel = cancelCount >= 3;

                  return Row(
                    children: [
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: ColorConstants.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating★ ($count)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ColorConstants.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 14,
                        width: 1,
                        color: ColorConstants.borderLightColor,
                      ),
                      const SizedBox(width: 12),

                      // Cancel count
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 14,
                            color: isHighCancel
                                ? ColorConstants.redShade700
                                : ColorConstants.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hủy đơn: $cancelCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isHighCancel
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isHighCancel
                                  ? ColorConstants.redShade700
                                  : ColorConstants.textSecondaryColor,
                            ),
                          ),
                          if (isHighCancel) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: ColorConstants.redShade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Cần lưu ý',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConstants.redShade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
