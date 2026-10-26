import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

import '../../domain/entities/post_history_status.dart';

class PostHistoryStatusFilterBar extends StatelessWidget {
  const PostHistoryStatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final PostHistoryStatus? selectedStatus;
  final ValueChanged<PostHistoryStatus?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildChip(label: 'Tất cả', status: null),
            _buildChip(
              label: PostHistoryStatus.daAn.label,
              status: PostHistoryStatus.daAn,
            ),
            _buildChip(
              label: PostHistoryStatus.dangHienThi.label,
              status: PostHistoryStatus.dangHienThi,
            ),
            _buildChip(
              label: PostHistoryStatus.daDatGiu.label,
              status: PostHistoryStatus.daDatGiu,
            ),
            _buildChip(
              label: PostHistoryStatus.daBan.label,
              status: PostHistoryStatus.daBan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required PostHistoryStatus? status,
  }) {
    final isSelected = selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onStatusSelected(status),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorConstants.primaryColor
                : ColorConstants.greyShade100,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.borderLightColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : ColorConstants.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
