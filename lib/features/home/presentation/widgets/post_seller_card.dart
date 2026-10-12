import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import '../../domain/entities/address.dart';
import 'home_formatters.dart';

class PostSellerCard extends StatelessWidget {
  const PostSellerCard({
    super.key,
    required this.authorName,
    required this.createdAt,
    required this.address,
    this.onContactTap,
  });

  final String authorName;
  final DateTime createdAt;
  final Address address;
  final VoidCallback? onContactTap;

  @override
  Widget build(BuildContext context) {
    final initial = authorName.trim().isNotEmpty
        ? authorName.trim()[0].toUpperCase()
        : 'S';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.greyShade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: ColorConstants.blue.withAlpha(35),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                          color: ColorConstants.greyShade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Đăng ${HomeFormatters.formatRelativeTime(createdAt)}\n'
                  'Địa điểm: ${address.label}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorConstants.greyShade600,
                  ),
                ),
              ],
            ),
          ),
          if (onContactTap != null)
            IconButton(
              onPressed: onContactTap,
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: ColorConstants.primaryColor,
              ),
              tooltip: 'Nhắn tin người bán',
            ),
        ],
      ),
    );
  }
}
