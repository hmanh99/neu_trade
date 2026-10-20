import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/review/domain/entities/rating_summary_entity.dart';
import 'package:neu_trade/features/review/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, ReviewEntity>> submitReview({
    required int transactionId,
    required int stars,
    String? content,
  });

  Future<Either<Failure, RatingSummaryEntity>> getRatingSummary({
    required String targetUserId,
  });
}
