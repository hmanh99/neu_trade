import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.greyShade300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: ColorConstants.greyShade600,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Tìm giáo trình, đề thi, slide NEU...',
                hintStyle: TextStyle(
                  color: ColorConstants.greyShade500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: ColorConstants.greyShade900,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
                onClear?.call();
              },
              child: const Icon(
                Icons.cancel,
                color: ColorConstants.greyShade500,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
