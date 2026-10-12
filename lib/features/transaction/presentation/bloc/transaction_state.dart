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
  const TransactionFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class TransactionCompleteSuccessState extends TransactionState {
  const TransactionCompleteSuccessState({
    required this.transactions,
    required this.message,
  });

  final List<TransactionEntity> transactions;
  final String message;

  @override
  List<Object?> get props => [transactions, message];
}
