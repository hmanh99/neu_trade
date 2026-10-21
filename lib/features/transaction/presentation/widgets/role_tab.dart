import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart'
    show ColorConstants;

class RoleTab extends StatelessWidget {
  const RoleTab({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1),
        padding: const EdgeInsets.symmetric(vertical: 10),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.textSecondaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? ColorConstants.primaryColor
                    : ColorConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
