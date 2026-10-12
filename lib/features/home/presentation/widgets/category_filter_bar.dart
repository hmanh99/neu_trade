import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import '../../domain/entities/category.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final categories = Category.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Tất cả',
            icon: Icons.apps_rounded,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),
          ...categories.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: category.label,
                icon: _getCategoryIcon(category),
                isSelected: isSelected,
                onTap: () => onCategorySelected(isSelected ? null : category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: ColorConstants.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorConstants.primaryColor
                : ColorConstants.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.greyShade300,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? ColorConstants.white
                    : ColorConstants.greyShade700,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? ColorConstants.white
                      : ColorConstants.greyShade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.giaoTrinh:
        return Icons.menu_book_rounded;
      case Category.doAn:
        return Icons.assignment_outlined;
      case Category.slideIn:
        return Icons.slideshow_rounded;
      case Category.sachBaiTap:
        return Icons.edit_note_rounded;
    }
  }
}
