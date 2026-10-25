import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/services/profile_services.dart';

import '../../domain/entities/status.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/cancel_transaction_sheet.dart';
import '../widgets/review_bottom_sheet.dart';
import '../widgets/role_tab.dart';
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
  final Map<String, Future<int?>> _cancelCountCache = {};

  Future<String> _getPhone(String userId) async {
    final result = await _profileServices.getProfile(userId: userId);
    final phone = result?['so_dien_thoai']?.toString().trim();
    return (phone != null && phone.isNotEmpty) ? phone : 'Chưa cập nhật';
  }

  Future<int?> _getCancelCount(String userId) async {
    final stats = await _profileServices.getUserPublicStats(userId: userId);
    return (stats?['so_lan_huy_don'] as num?)?.toInt();
  }

  Future<void> _promptCancel(TransactionEntity item) async {
    final isBuying = item.buyerId == widget.currentUserId;
    final reason = await CancelTransactionSheet.show(
      context: context,
      postTitle: item.postTitle,
      isBuyer: isBuying,
    );

    if (reason != null && mounted) {
      context.read<TransactionBloc>().add(
        TransactionCancelRequested(
          transactionId: item.transactionId,
          reason: reason,
        ),
      );
    }
  }

  Future<void> _promptReview(TransactionEntity item) async {
    final isBuying = item.buyerId == widget.currentUserId;
    final targetName = isBuying ? item.sellerName : item.buyerName;

    final result = await ReviewBottomSheet.show(
      context: context,
      targetUserName: targetName,
      postTitle: item.postTitle,
      isEvaluatingSeller: isBuying,
    );

    if (result != null && mounted) {
      context.read<TransactionBloc>().add(
        TransactionReviewSubmitted(
          transactionId: item.transactionId,
          stars: result.stars,
          content: result.content,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionCompleteSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.snackBarSuccessColor,
            ),
          );
          _promptReview(state.completedTransaction);
        } else if (state is TransactionCancelSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.snackBarSuccessColor,
            ),
          );
        } else if (state is TransactionReviewSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.snackBarSuccessColor,
            ),
          );
        } else if (state is TransactionFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.snackBarFailedColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Giao dịch của tôi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.4,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Làm mới',
                onPressed: () {
                  context.read<TransactionBloc>().add(
                    const TransactionRefreshRequested(),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(TransactionState state) {
    if (state is TransactionLoadingState) {
      return const Center(
        child: CircularProgressIndicator(color: ColorConstants.primaryColor),
      );
    }

    final allTransactions = _extractTransactions(state);

    final items = allTransactions.where((t) {
      final isBuying = t.buyerId == widget.currentUserId;
      if (isBuying != _buying) return false;
      if (_statusFilter == 'Tất cả') return true;
      return t.status.label == _statusFilter;
    }).toList();


    return RefreshIndicator(
      color: ColorConstants.primaryColor,
      onRefresh: () async {
        context.read<TransactionBloc>().add(
          const TransactionRefreshRequested(),
        );
      },
      child: ListView(
        key: const PageStorageKey('transactions-scroll'),
        padding: const EdgeInsets.all(20),
        children: [
          // Tab: Tôi mua / Tôi bán
          Container(
            decoration: BoxDecoration(
              color: ColorConstants.greyShade100,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: RoleTab(
                    title: 'Tôi mua',
                    icon: Icons.shopping_bag_outlined,
                    isSelected: _buying,
                    onTap: () => setState(() => _buying = true),
                  ),
                ),
                Expanded(
                  child: RoleTab(
                    title: 'Tôi bán',
                    icon: Icons.sell_outlined,
                    isSelected: !_buying,
                    onTap: () => setState(() => _buying = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
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
                      selectedColor: ColorConstants.primaryLightBg,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: status == _statusFilter
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: status == _statusFilter
                            ? ColorConstants.primaryColor
                            : ColorConstants.textSecondaryColor,
                      ),
                      side: BorderSide(
                        color: status == _statusFilter
                            ? ColorConstants.primaryColor
                            : ColorConstants.borderLightColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (_) => setState(() => _statusFilter = status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: ColorConstants.primaryLightBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 32,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có giao dịch nào',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _buying
                        ? 'Các tài liệu bạn đặt trước sẽ hiển thị ở đây'
                        : 'Các đơn yêu cầu mua tài liệu của bạn sẽ hiển thị ở đây',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ColorConstants.textSecondaryColor,
                      fontSize: 13,
                    ),
                  ),
                ],
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
                builder: (context, phoneSnapshot) {
                  final phone = phoneSnapshot.data ?? 'Đang tải số điện thoại...';
                  final isBuyingItem = item.buyerId == widget.currentUserId;

                  if (!isBuyingItem) {
                    return FutureBuilder<int?>(
                      future: _cancelCountCache.putIfAbsent(
                        item.buyerId,
                        () => _getCancelCount(item.buyerId),
                      ),
                      builder: (context, cancelSnapshot) => TransactionCard(
                        item: item,
                        phone: phone,
                        isBuying: false,
                        currentUserId: widget.currentUserId,
                        buyerCancelCount: cancelSnapshot.data,
                        onComplete: item.status == Status.DangGiuCho &&
                                item.sellerId == widget.currentUserId
                            ? () {
                                context.read<TransactionBloc>().add(
                                  TransactionCompleteRequested(
                                    item.transactionId,
                                  ),
                                );
                              }
                            : null,
                        onCancel: item.status == Status.DangGiuCho
                            ? () => _promptCancel(item)
                            : null,
                        onReview:
                            (item.status == Status.HoanTat && !item.hasReviewed)
                                ? () => _promptReview(item)
                                : null,
                      ),
                    );
                  }

                  return TransactionCard(
                    item: item,
                    phone: phone,
                    isBuying: true,
                    currentUserId: widget.currentUserId,
                    onCancel: item.status == Status.DangGiuCho
                        ? () => _promptCancel(item)
                        : null,
                    onReview:
                        (item.status == Status.HoanTat && !item.hasReviewed)
                            ? () => _promptReview(item)
                            : null,
                  );
                },
              ),

        ],
      ),
    );
  }


  List<TransactionEntity> _extractTransactions(TransactionState state) {
    if (state is TransactionLoadedState) return state.transactions;
    if (state is TransactionCompleteSuccessState) return state.transactions;
    if (state is TransactionReviewSuccessState) return state.transactions;
    if (state is TransactionFailureState) return state.transactions;
    return [];
  }
}
