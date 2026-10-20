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

class TransactionCancelRequested extends TransactionEvent {
  const TransactionCancelRequested({
    required this.transactionId,
    this.reason,
  });

  final int transactionId;
  final String? reason;

  @override
  List<Object?> get props => [transactionId, reason];
}

class TransactionReviewSubmitted extends TransactionEvent {
  const TransactionReviewSubmitted({
    required this.transactionId,
    required this.stars,
    this.content,
  });

  final int transactionId;
  final int stars;
  final String? content;

  @override
  List<Object?> get props => [transactionId, stars, content];
}
