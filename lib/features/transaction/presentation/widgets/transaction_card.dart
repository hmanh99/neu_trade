import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

import '../../domain/entities/status.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.item,
    required this.isBuying,
    this.currentUserId,
    this.onComplete,
    this.onCancel,
    this.onReview,
    required this.phone,
    this.buyerCancelCount,
  });

  final String phone;
  final TransactionEntity item;
  final bool isBuying;
  final String? currentUserId;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final int? buyerCancelCount;

  String _cancelledByText() {
    if (item.cancelledById == null || item.cancelledById!.isEmpty) {
      return 'Hệ thống (Quá hạn 48h)';
    }
    if (currentUserId != null && item.cancelledById == currentUserId) {
      return 'bạn';
    }
    if (item.cancelledById == item.buyerId) {
      return isBuying ? 'bạn' : 'người mua';
    }
    if (item.cancelledById == item.sellerId) {
      return isBuying ? 'người bán' : 'bạn';
    }
    return 'đối tác';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      Status.HoanTat => ColorConstants.greenShade600,
      Status.DangGiuCho => ColorConstants.primaryColor,
      Status.DaHuy => ColorConstants.redShade700,
    };

    final statusBg = switch (item.status) {
      Status.HoanTat => ColorConstants.greenShade50,
      Status.DangGiuCho => ColorConstants.blueShade50,
      Status.DaHuy => ColorConstants.redShade50,
    };

    final dateFormat = DateFormat('dd/MM · HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _showDetails(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.status.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateFormat.format(item.orderTime.toLocal()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.postTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ColorConstants.textPrimaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorConstants.greyShade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isBuying ? Icons.storefront_rounded : Icons.person_rounded,
                            size: 15,
                            color: ColorConstants.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isBuying ? 'Người bán: ' : 'Người mua: ',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: ColorConstants.textSecondaryColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              isBuying ? item.sellerName : item.buyerName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: ColorConstants.textPrimaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isBuying && buyerCancelCount != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: buyerCancelCount! >= 3
                                    ? ColorConstants.redShade50
                                    : ColorConstants.greyShade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: buyerCancelCount! >= 3
                                      ? ColorConstants.redShade200
                                      : ColorConstants.borderLightColor,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event_busy_rounded,
                                    size: 10,
                                    color: buyerCancelCount! >= 3
                                        ? ColorConstants.redShade700
                                        : ColorConstants.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Hủy: $buyerCancelCount',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: buyerCancelCount! >= 3
                                          ? ColorConstants.redShade700
                                          : ColorConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 15,
                            color: ColorConstants.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'SĐT: ',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: ColorConstants.textSecondaryColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.textPrimaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Cancellation banner if DaHuy
                if (item.status == Status.DaHuy) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.redShade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorConstants.redShade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: ColorConstants.redShade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Đã hủy bởi ${_cancelledByText()}'
                            '${item.cancelReason != null && item.cancelReason!.isNotEmpty ? ' (${item.cancelReason})' : ''}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.redShade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatCurrency(item.price),
                        style: const TextStyle(
                          fontSize: 18,
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (item.status == Status.DangGiuCho) ...[
                      if (onCancel != null)
                        OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.close_rounded, size: 14),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorConstants.redShade700,
                            side: const BorderSide(
                              color: ColorConstants.redShade200,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          label: const Text(
                            'Hủy đơn',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (onComplete != null) ...[
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: onComplete,
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: ColorConstants.greenShade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          label: const Text(
                            'Hoàn tất',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ] else if (item.status == Status.HoanTat)
                      if (item.hasReviewed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.orangeShade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColorConstants.orangeShade100,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: ColorConstants.warningColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.myStars != null
                                    ? 'Đã đánh giá ${item.myStars}★'
                                    : 'Đã đánh giá',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConstants.orangeShade700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (onReview != null)
                        OutlinedButton.icon(
                          onPressed: onReview,
                          icon: const Icon(Icons.star_outline_rounded, size: 16),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorConstants.warningColor,
                            side: const BorderSide(
                              color: ColorConstants.warningColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          label: const Text(
                            'Đánh giá',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price)} đ';
  }

  void _showDetails(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.postTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorConstants.greyShade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorConstants.borderLightColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.person_outline_rounded,
                      color: ColorConstants.primaryColor,
                    ),
                    title: Text(
                      isBuying ? item.sellerName : item.buyerName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      isBuying
                          ? 'Người bán'
                          : (buyerCancelCount != null
                              ? 'Người mua · Đã hủy $buyerCancelCount đơn'
                              : 'Người mua'),
                    ),
                  ),
                  const Divider(color: ColorConstants.borderLightColor),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.phone_outlined,
                      color: ColorConstants.primaryColor,
                    ),
                    title: Text(
                      phone,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Số điện thoại liên hệ'),
                  ),
                  const Divider(color: ColorConstants.borderLightColor),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.place_outlined,
                      color: ColorConstants.primaryColor,
                    ),
                    title: Text(
                      item.address.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Thời gian đặt: ${DateFormat('dd/MM/yyyy · HH:mm').format(item.orderTime.toLocal())}',
                    ),
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const Divider(color: ColorConstants.borderLightColor),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.notes_rounded,
                        color: ColorConstants.primaryColor,
                      ),
                      title: Text(
                        item.note!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Ghi chú giao dịch'),
                    ),
                  ],
                  if (item.status == Status.DangGiuCho) ...[
                    const Divider(color: ColorConstants.borderLightColor),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.timer_outlined,
                        color: ColorConstants.warningColor,
                      ),
                      title: Text(
                        DateFormat('dd/MM/yyyy · HH:mm').format(
                          item.expireTime.toLocal(),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.warningColor,
                        ),
                      ),
                      subtitle: const Text('Thời hạn giữ chỗ (48 giờ)'),
                    ),
                  ],
                  if (item.status == Status.DaHuy) ...[
                    const Divider(color: ColorConstants.borderLightColor),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.cancel_rounded,
                        color: ColorConstants.redShade700,
                      ),
                      title: Text(
                        'Đã hủy bởi ${_cancelledByText()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.redShade700,
                        ),
                      ),
                      subtitle: Text(
                        item.cancelReason != null && item.cancelReason!.isNotEmpty
                            ? 'Lý do: ${item.cancelReason}'
                            : (item.cancelledAt != null
                                ? 'Thời gian hủy: ${DateFormat('dd/MM/yyyy · HH:mm').format(item.cancelledAt!.toLocal())}'
                                : 'Đã hủy giao dịch'),
                      ),
                    ),
                  ],
                  if (item.status == Status.HoanTat && item.hasReviewed) ...[
                    const Divider(color: ColorConstants.borderLightColor),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.star_rounded,
                        color: ColorConstants.warningColor,
                      ),
                      title: Text(
                        item.myStars != null
                            ? 'Đã đánh giá: ${item.myStars}/5 sao'
                            : 'Đã hoàn tất đánh giá',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text('Trạng thái đánh giá của bạn'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorConstants.primaryLightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trạng thái: ${item.status.label}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  Text(
                    _formatCurrency(item.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (item.status == Status.DangGiuCho && onCancel != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCancel!();
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorConstants.redShade700,
                    side: const BorderSide(color: ColorConstants.redShade200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    'Hủy giao dịch này',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
            if (item.status == Status.HoanTat && !item.hasReviewed && onReview != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onReview!();
                  },
                  icon: const Icon(Icons.star_rounded, size: 18),
                  style: FilledButton.styleFrom(
                    backgroundColor: ColorConstants.warningColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    'Đánh giá giao dịch này',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
