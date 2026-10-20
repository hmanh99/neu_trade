import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'home_formatters.dart';

class PostBottomBar extends StatelessWidget {
  const PostBottomBar({
    super.key,
    required this.price,
    required this.isOwner,
    required this.isAvailable,
    required this.onReserveTap,
  });

  final double price;
  final bool isOwner;
  final bool isAvailable;
  final VoidCallback onReserveTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: ColorConstants.borderLightColor),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price column
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giá bán',
                style: TextStyle(
                  fontSize: 12,
                  color: ColorConstants.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                HomeFormatters.formatCurrency(price),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Action button
          Expanded(
            child: SizedBox(
              height: 48,
              child: _buildActionButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (isOwner) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.person_pin_outlined, size: 20),
        label: const Text(
          'Bài đăng của bạn',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    if (!isAvailable) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.greyShade200,
          foregroundColor: ColorConstants.greyShade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Đã có người đặt',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return Container(
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
      child: ElevatedButton.icon(
        onPressed: onReserveTap,
        icon: const Icon(Icons.shopping_bag_outlined, size: 19),
        label: const Text(
          'Đặt trước ngay',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
