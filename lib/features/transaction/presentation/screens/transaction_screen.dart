import 'package:flutter/material.dart';

class _Transaction {
  const _Transaction(
    this.title,
    this.person,
    this.price,
    this.status,
    this.isBuying,
    this.date,
    this.place,
  );
  final String title, person, price, status, date, place;
  final bool isBuying;
}

const _transactions = [
  _Transaction(
    'Giáo trình Kinh tế vi mô',
    'Minh Anh',
    '45.000 đ',
    'Chờ xác nhận',
    true,
    '28/09 · 14:30',
    'Thư viện NEU',
  ),
  _Transaction(
    'English for Business',
    'Thu Hà',
    '60.000 đ',
    'Đang hẹn',
    true,
    '28/09 · 16:00',
    'Cổng Trần Đại Nghĩa',
  ),
  _Transaction(
    'Marketing căn bản',
    'Hoàng Nam',
    '35.000 đ',
    'Hoàn tất',
    false,
    '26/09 · 10:00',
    'Sảnh nhà A2',
  ),
  _Transaction(
    'Bộ đề Nguyên lý kế toán',
    'Đức Anh',
    '25.000 đ',
    'Hoàn tất',
    true,
    '24/09 · 09:00',
    'Thư viện NEU',
  ),
];

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});
  @override
  State<TransactionScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionScreen> {
  bool _buying = true;
  String _status = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final items = _transactions
        .where(
          (t) =>
              t.isBuying == _buying &&
              (_status == 'Tất cả' || t.status == _status),
        )
        .toList();
    return  ListView(
        key: const PageStorageKey('transactions-scroll'),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEF9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _Summary(value: '02', label: 'Đang trao đổi'),
                ),
                SizedBox(height: 44, child: VerticalDivider()),
                Expanded(
                  child: _Summary(value: '02', label: 'Đã hoàn tất'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Tôi mua'),
                icon: Icon(Icons.shopping_bag_outlined),
              ),
              ButtonSegment(
                value: false,
                label: Text('Tôi bán'),
                icon: Icon(Icons.sell_outlined),
              ),
            ],
            selected: {_buying},
            onSelectionChanged: (selection) =>
                setState(() => _buying = selection.first),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final status in [
                  'Tất cả',
                  'Chờ xác nhận',
                  'Đang hẹn',
                  'Hoàn tất',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: status == _status,
                      onSelected: (_) => setState(() => _status = status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lịch sử giao dịch mẫu',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          for (final item in items) _TransactionCard(item: item),
        ],

    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.blue,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
    ],
  );
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.item});
  final _Transaction item;
  @override
  Widget build(BuildContext context) {
    final color = item.status == 'Hoàn tất'
        ? const Color(0xFF237853)
        : item.status == 'Đang hẹn'
        ? Colors.blue
        : const Color(0xFF996C13);
    return Card(
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
                    item.status,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.isBuying ? 'Người bán' : 'Người mua'}: ${item.person}',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.price,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _details(context),
                  child: const Text('Chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _details(BuildContext context) => showModalBottomSheet<void>(
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
              item.title,
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
              title: Text(item.person),
              subtitle: Text(item.isBuying ? 'Người bán' : 'Người mua'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(item.place),
              subtitle: Text(item.date),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.status),
              trailing: Text(
                item.price,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Giao dịch mẫu để xem trước giao diện.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    ),
  );
}
