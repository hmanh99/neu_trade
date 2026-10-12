import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested();
}

class TransactionRefreshRequested extends TransactionEvent {
  const TransactionRefreshRequested();
}

class TransactionCompleteRequested extends TransactionEvent {
  const TransactionCompleteRequested(this.transactionId);

  final int transactionId;

  @override
  List<Object?> get props => [transactionId];
}
