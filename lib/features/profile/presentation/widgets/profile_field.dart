import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: ColorConstants.primaryLightBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: ColorConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.trim().isEmpty ? 'Chưa cập nhật' : value,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
