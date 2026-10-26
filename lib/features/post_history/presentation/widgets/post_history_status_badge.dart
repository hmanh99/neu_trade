import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

import '../../domain/entities/post_history_status.dart';

class PostHistoryStatusBadge extends StatelessWidget {
  const PostHistoryStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final PostHistoryStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            size: compact ? 12 : 14,
            color: style.foreground,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }

  static ({Color background, Color foreground, Color border, IconData icon})
  _styleFor(PostHistoryStatus status) {
    switch (status) {
      case PostHistoryStatus.daAn:
        return (
          background: ColorConstants.orangeShade50,
          foreground: ColorConstants.orangeShade700,
          border: ColorConstants.orangeShade100,
          icon: Icons.hourglass_top_rounded,
        );
      case PostHistoryStatus.dangHienThi:
        return (
          background: ColorConstants.greenShade50,
          foreground: ColorConstants.greenShade700,
          border: ColorConstants.greenShade100,
          icon: Icons.visibility_rounded,
        );
      case PostHistoryStatus.daDatGiu:
        return (
          background: ColorConstants.blueShade50,
          foreground: ColorConstants.blueShade700,
          border: ColorConstants.blueShade100,
          icon: Icons.bookmark_added_rounded,
        );
      case PostHistoryStatus.daBan:
        return (
          background: ColorConstants.greyShade100,
          foreground: ColorConstants.greyShade700,
          border: ColorConstants.greyShade200,
          icon: Icons.check_circle_rounded,
        );
    }
  }
}
