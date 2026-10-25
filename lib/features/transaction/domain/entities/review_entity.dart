import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int reviewId;
  final int transactionId;
  final String reviewerId;
  final String targetUserId;
  final int stars;
  final String? content;
  final DateTime createdAt;

  const ReviewEntity({
    required this.reviewId,
    required this.transactionId,
    required this.reviewerId,
    required this.targetUserId,
    required this.stars,
    this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    reviewId,
    transactionId,
    reviewerId,
    targetUserId,
    stars,
    content,
    createdAt,
  ];
}
