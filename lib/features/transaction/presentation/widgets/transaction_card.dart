import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/status.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key,
    required this.item,
    required this.isBuying,
    this.onComplete,
    required this.phone,
  });

  final String phone;
  final TransactionEntity item;
  final bool isBuying;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.status) {
      Status.HoanTat => const Color(0xFF237853),
      Status.DangGiuCho => Colors.blue,
      Status.DaHuy => const Color(0xFF996C13),
    };

    final dateFormat = DateFormat('dd/MM · HH:mm');

    return InkWell(
      onTap: () => _showDetails(context),
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE7ECF3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    dateFormat.format(item.orderTime.toLocal()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.postTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${isBuying ? 'Người bán' : 'Người mua'}: ${isBuying ? item.sellerName : item.buyerName}',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Text(
                'Số điện thoại: $phone',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatCurrency(item.price),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (onComplete != null)
                    FilledButton.tonal(
                      onPressed: onComplete,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF237853,
                        ).withValues(alpha: .1),
                        foregroundColor: const Color(0xFF237853),
                      ),
                      child: const Text('Hoàn tất'),
                    ),
                ],
              ),
            ],
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
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(isBuying ? item.sellerName : item.buyerName),
              subtitle: Text(isBuying ? 'Người bán' : 'Người mua'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_outlined),
              title: Text(phone),
              subtitle: const Text('Số điện thoại'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(item.address.label),
              subtitle: Text(
                DateFormat(
                  'dd/MM/yyyy · HH:mm',
                ).format(item.orderTime.toLocal()),
              ),
            ),
            if (item.note != null && item.note!.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notes_outlined),
                title: Text(item.note!),
                subtitle: const Text('Ghi chú'),
              ),
            if (item.status == Status.DangGiuCho) ...[
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timer_outlined, color: Colors.orange),
                title: Text(
                  'Hết hạn: ${DateFormat('dd/MM/yyyy · HH:mm').format(item.expireTime.toLocal())}',
                ),
                subtitle: const Text('Thời gian giữ chỗ'),
              ),
            ],
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.status.label),
              trailing: Text(
                _formatCurrency(item.price),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
