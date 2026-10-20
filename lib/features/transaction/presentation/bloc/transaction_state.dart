import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitialState extends TransactionState {
  const TransactionInitialState();
}

class TransactionLoadingState extends TransactionState {
  const TransactionLoadingState();
}

class TransactionLoadedState extends TransactionState {
  const TransactionLoadedState({
    required this.transactions,
  });

  final List<TransactionEntity> transactions;

  TransactionLoadedState copyWith({
    List<TransactionEntity>? transactions,
  }) {
    return TransactionLoadedState(
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [transactions];
}

class TransactionFailureState extends TransactionState {
  const TransactionFailureState({
    required this.message,
    this.transactions = const [],
  });

  final String message;
  final List<TransactionEntity> transactions;

  @override
  List<Object?> get props => [message, transactions];
}

class TransactionCompleteSuccessState extends TransactionState {
  const TransactionCompleteSuccessState({
    required this.transactions,
    required this.completedTransaction,
    required this.message,
  });

  final List<TransactionEntity> transactions;
  final TransactionEntity completedTransaction;
  final String message;

  @override
  List<Object?> get props => [transactions, completedTransaction, message];
}

class TransactionCancelSuccessState extends TransactionState {
  const TransactionCancelSuccessState({
    required this.transactions,
    required this.cancelledTransaction,
    required this.message,
  });

  final List<TransactionEntity> transactions;
  final TransactionEntity cancelledTransaction;
  final String message;

  @override
  List<Object?> get props => [transactions, cancelledTransaction, message];
}

class TransactionReviewSuccessState extends TransactionState {
  const TransactionReviewSuccessState({
    required this.transactions,
    required this.message,
  });

  final List<TransactionEntity> transactions;
  final String message;

  @override
  List<Object?> get props => [transactions, message];
}
