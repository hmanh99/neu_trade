import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/services/profile_services.dart';

import '../../domain/entities/status.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/summary.dart';
import '../widgets/transaction_card.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key, required this.currentUserId});

  final String currentUserId;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool _buying = true;
  String _statusFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const TransactionLoadRequested());
  }

  final ProfileServices _profileServices = ProfileServices();
  final Map<String, Future<String>> _phoneCache = {};

  Future<String> _getPhone(String userId) async {
    final result = await _profileServices.getProfile(userId: userId);
    final phone = result?['so_dien_thoai']?.toString().trim();
    return (phone != null && phone.isNotEmpty) ? phone : 'Chưa cập nhật';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionCompleteSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF237853),
            ),
          );
        } else if (state is TransactionFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("state.message"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TransactionLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTransactions = _extractTransactions(state);

        final items = allTransactions.where((t) {
          final isBuying = t.buyerId == widget.currentUserId;
          if (isBuying != _buying) return false;
          if (_statusFilter == 'Tất cả') return true;
          return t.status.label == _statusFilter;
        }).toList();

        final activeCount = allTransactions
            .where((t) => t.status == Status.DangGiuCho)
            .length;
        final doneCount = allTransactions
            .where((t) => t.status == Status.HoanTat)
            .length;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(
              const TransactionRefreshRequested(),
            );
          },
          child: ListView(
            key: const PageStorageKey('transactions-scroll'),
            padding: const EdgeInsets.all(20),
            children: [
              // Summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EEF9),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Summary(
                        value: activeCount.toString().padLeft(2, '0'),
                        label: 'Đang trao đổi',
                      ),
                    ),
                    const SizedBox(height: 44, child: VerticalDivider()),
                    Expanded(
                      child: Summary(
                        value: doneCount.toString().padLeft(2, '0'),
                        label: 'Đã hoàn tất',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab: Tôi mua / Tôi bán
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

              // Status filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final status in [
                      'Tất cả',
                      'Đang giữ chỗ',
                      'Hoàn tất',
                      'Đã hủy',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: status == _statusFilter,
                          onSelected: (_) =>
                              setState(() => _statusFilter = status),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'Chưa có giao dịch nào.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ),
                )
              else
                for (final item in items)
                  FutureBuilder<String>(
                    future: _phoneCache.putIfAbsent(
                      item.buyerId == widget.currentUserId
                          ? item.sellerId
                          : item.buyerId,
                      () => _getPhone(
                        item.buyerId == widget.currentUserId
                            ? item.sellerId
                            : item.buyerId,
                      ),
                    ),
                    builder: (context, snapshot) => TransactionCard(
                      item: item,
                      phone: snapshot.data ?? 'Đang tải số điện thoại...',
                      isBuying: item.buyerId == widget.currentUserId,
                      onComplete:
                          item.status == Status.DangGiuCho &&
                              item.sellerId == widget.currentUserId
                          ? () {
                              context.read<TransactionBloc>().add(
                                TransactionCompleteRequested(
                                  item.transactionId,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  List<TransactionEntity> _extractTransactions(TransactionState state) {
    if (state is TransactionLoadedState) return state.transactions;
    if (state is TransactionCompleteSuccessState) return state.transactions;
    return [];
  }
}
