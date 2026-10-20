import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: ColorConstants.primaryLightBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: ColorConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Không tìm thấy tài liệu',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: ColorConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: ColorConstants.textSecondaryColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorConstants.primaryColor,
                  side: const BorderSide(color: ColorConstants.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
