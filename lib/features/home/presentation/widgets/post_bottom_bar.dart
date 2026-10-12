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
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -4),
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
                  color: ColorConstants.greyShade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                HomeFormatters.formatCurrency(price),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.primaryColor,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text('Đã có người đặt'),
      );
    }

    return ElevatedButton.icon(
      onPressed: onReserveTap,
      icon: const Icon(Icons.shopping_bag_outlined, size: 20),
      label: const Text(
        'Đặt trước ngay',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: ColorConstants.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
