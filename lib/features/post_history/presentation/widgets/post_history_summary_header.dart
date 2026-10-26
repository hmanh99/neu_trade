import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

import '../../domain/entities/post_history_status.dart';
import '../bloc/post_history_state.dart';

class PostHistorySummaryHeader extends StatelessWidget {
  const PostHistorySummaryHeader({
    super.key,
    required this.state,
    required this.onStatusTap,
  });

  final PostHistoryLoadedState state;
  final ValueChanged<PostHistoryStatus?> onStatusTap;

  @override
  Widget build(BuildContext context) {
    final pendingCount = state.countByStatus(PostHistoryStatus.daAn);
    final visibleCount = state.countByStatus(PostHistoryStatus.dangHienThi);
    final reservedCount = state.countByStatus(PostHistoryStatus.daDatGiu);
    final soldCount = state.countByStatus(PostHistoryStatus.daBan);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: ColorConstants.softShadow,
      ),
      child: Row(
        children: [
          _buildItem(
            label: 'Chờ duyệt',
            count: pendingCount,
            color: ColorConstants.orangeShade700,
            bgColor: ColorConstants.orangeShade50,
            isSelected: state.selectedStatus == PostHistoryStatus.daAn,
            onTap: () => onStatusTap(
              state.selectedStatus == PostHistoryStatus.daAn
                  ? null
                  : PostHistoryStatus.daAn,
            ),
          ),
          _buildDivider(),
          _buildItem(
            label: 'Hiển thị',
            count: visibleCount,
            color: ColorConstants.greenShade700,
            bgColor: ColorConstants.greenShade50,
            isSelected: state.selectedStatus == PostHistoryStatus.dangHienThi,
            onTap: () => onStatusTap(
              state.selectedStatus == PostHistoryStatus.dangHienThi
                  ? null
                  : PostHistoryStatus.dangHienThi,
            ),
          ),
          _buildDivider(),
          _buildItem(
            label: 'Đặt giữ',
            count: reservedCount,
            color: ColorConstants.blueShade700,
            bgColor: ColorConstants.blueShade50,
            isSelected: state.selectedStatus == PostHistoryStatus.daDatGiu,
            onTap: () => onStatusTap(
              state.selectedStatus == PostHistoryStatus.daDatGiu
                  ? null
                  : PostHistoryStatus.daDatGiu,
            ),
          ),
          _buildDivider(),
          _buildItem(
            label: 'Đã bán',
            count: soldCount,
            color: ColorConstants.greyShade700,
            bgColor: ColorConstants.greyShade100,
            isSelected: state.selectedStatus == PostHistoryStatus.daBan,
            onTap: () => onStatusTap(
              state.selectedStatus == PostHistoryStatus.daBan
                  ? null
                  : PostHistoryStatus.daBan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: ColorConstants.borderLightColor,
    );
  }

  Widget _buildItem({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? bgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : ColorConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
