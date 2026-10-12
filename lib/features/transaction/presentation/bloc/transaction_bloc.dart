import 'package:bloc/bloc.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/complete_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required GetTransactionsUsecase getTransactions,
    required CompleteTransactionUsecase completeTransaction,
  })  : _getTransactions = getTransactions,
        _completeTransaction = completeTransaction,
        super(const TransactionInitialState()) {
    on<TransactionLoadRequested>(_onLoadRequested);
    on<TransactionRefreshRequested>(_onRefreshRequested);
    on<TransactionCompleteRequested>(_onCompleteRequested);
  }

  final GetTransactionsUsecase _getTransactions;
  final CompleteTransactionUsecase _completeTransaction;

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
    final currentState = state;
    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) {
        if (currentState is! TransactionLoadedState) {
          emit(TransactionFailureState(message: failure.message));
        }
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
      (failure) => emit(TransactionFailureState(message: failure.message)),
      (updatedTransaction) {
        // Replace the completed transaction in the list
        final updated = currentTransactions.map((t) {
          if (t.transactionId == updatedTransaction.transactionId) {
            return updatedTransaction;
          }
          return t;
        }).toList();

        emit(TransactionCompleteSuccessState(
          transactions: updated,
          message: 'Giao dịch đã hoàn tất thành công!',
        ));
      },
    );
  }

  List<TransactionEntity> _currentTransactions(TransactionState state) {
    if (state is TransactionLoadedState) return state.transactions;
    if (state is TransactionCompleteSuccessState) return state.transactions;
    return [];
  }
}
