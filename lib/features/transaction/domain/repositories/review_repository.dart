import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/transaction/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, ReviewEntity>> submitReview({
    required int transactionId,
    required int stars,
    String? content,
  });
}
