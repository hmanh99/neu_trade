import 'package:bloc/bloc.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/cancel_transaction_usecase.dart';
import '../../domain/usecases/complete_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/submit_review_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required GetTransactionsUsecase getTransactions,
    required CompleteTransactionUsecase completeTransaction,
    required CancelTransactionUsecase cancelTransaction,
    required SubmitReviewUsecase submitReview,
  })  : _getTransactions = getTransactions,
        _completeTransaction = completeTransaction,
        _cancelTransaction = cancelTransaction,
        _submitReview = submitReview,
        super(const TransactionInitialState()) {
    on<TransactionLoadRequested>(_onLoadRequested);
    on<TransactionRefreshRequested>(_onRefreshRequested);
    on<TransactionCompleteRequested>(_onCompleteRequested);
    on<TransactionCancelRequested>(_onCancelRequested);
    on<TransactionReviewSubmitted>(_onReviewSubmitted);
  }

  final GetTransactionsUsecase _getTransactions;
  final CompleteTransactionUsecase _completeTransaction;
  final CancelTransactionUsecase _cancelTransaction;
  final SubmitReviewUsecase _submitReview;

  Future<void> _onLoadRequested(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoadingState());
    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) => emit(TransactionFailureState(message: failure.message)),
      (transactions) => emit(
        TransactionLoadedState(transactions: transactions),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    TransactionRefreshRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentTransactions = _currentTransactions(state);
    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) {
        emit(TransactionFailureState(
          message: failure.message,
          transactions: currentTransactions,
        ));
      },
      (transactions) {
        emit(TransactionLoadedState(transactions: transactions));
      },
    );
  }

  Future<void> _onCompleteRequested(
    TransactionCompleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentTransactions = _currentTransactions(state);

    final result = await _completeTransaction(
      CompleteTransactionParams(transactionId: event.transactionId),
    );

    result.fold(
      (failure) => emit(TransactionFailureState(
        message: failure.message,
        transactions: currentTransactions,
      )),
      (updatedTransaction) {
        final updated = currentTransactions.map((t) {
          if (t.transactionId == updatedTransaction.transactionId) {
            return updatedTransaction;
          }
          return t;
        }).toList();

        emit(TransactionCompleteSuccessState(
          transactions: updated,
          completedTransaction: updatedTransaction,
          message: 'Giao dịch đã hoàn tất thành công!',
        ));
      },
    );
  }

  Future<void> _onCancelRequested(
    TransactionCancelRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentTransactions = _currentTransactions(state);

    final result = await _cancelTransaction(
      CancelTransactionParams(
        transactionId: event.transactionId,
        reason: event.reason,
      ),
    );

    result.fold(
      (failure) => emit(TransactionFailureState(
        message: failure.message,
        transactions: currentTransactions,
      )),
      (cancelledTransaction) {
        final updated = currentTransactions.map((t) {
          if (t.transactionId == cancelledTransaction.transactionId) {
            return cancelledTransaction;
          }
          return t;
        }).toList();

        emit(TransactionCancelSuccessState(
          transactions: updated,
          cancelledTransaction: cancelledTransaction,
          message: 'Đã hủy giao dịch.',
        ));
      },
    );
  }

  Future<void> _onReviewSubmitted(
    TransactionReviewSubmitted event,
    Emitter<TransactionState> emit,
  ) async {
    final currentTransactions = _currentTransactions(state);

    final result = await _submitReview(
      SubmitReviewParams(
        transactionId: event.transactionId,
        stars: event.stars,
        content: event.content,
      ),
    );

    result.fold(
      (failure) => emit(TransactionFailureState(
        message: failure.message,
        transactions: currentTransactions,
      )),
      (review) {
        final updated = currentTransactions.map((t) {
          if (t.transactionId == event.transactionId) {
            return t.copyWith(
              hasReviewed: true,
              myStars: event.stars,
            );
          }
          return t;
        }).toList();

        emit(TransactionReviewSuccessState(
          transactions: updated,
          message: 'Cảm ơn bạn đã gửi đánh giá!',
        ));
      },
    );
  }

  List<TransactionEntity> _currentTransactions(TransactionState state) {
    if (state is TransactionLoadedState) return state.transactions;
    if (state is TransactionCompleteSuccessState) return state.transactions;
    if (state is TransactionCancelSuccessState) return state.transactions;
    if (state is TransactionReviewSuccessState) return state.transactions;
    if (state is TransactionFailureState) return state.transactions;
    return [];
  }
}
