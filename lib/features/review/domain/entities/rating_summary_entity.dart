import 'package:equatable/equatable.dart';

class RatingSummaryEntity extends Equatable {
  final String userId;
  final double averageRating;
  final int totalReviews;

  const RatingSummaryEntity({
    required this.userId,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [userId, averageRating, totalReviews];
}
