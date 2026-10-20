import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class Summary extends StatelessWidget {
  const Summary({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  final String value, label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? ColorConstants.primaryColor;

    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: effectiveColor),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: effectiveColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
