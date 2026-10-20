import 'package:equatable/equatable.dart';

class UserPublicStats extends Equatable {
  final String userId;
  final double averageRating;
  final int totalReviews;
  final int cancelledOrderCount;
  final int totalCompleted;

  const UserPublicStats({
    required this.userId,
    required this.averageRating,
    required this.totalReviews,
    required this.cancelledOrderCount,
    required this.totalCompleted,
  });

  const UserPublicStats.empty([String id = ''])
      : userId = id,
        averageRating = 5.0,
        totalReviews = 0,
        cancelledOrderCount = 0,
        totalCompleted = 0;

  @override
  List<Object?> get props => [
        userId,
        averageRating,
        totalReviews,
        cancelledOrderCount,
        totalCompleted,
      ];
}
