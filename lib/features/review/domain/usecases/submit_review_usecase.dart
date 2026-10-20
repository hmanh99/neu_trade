import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/review/domain/entities/review_entity.dart';
import 'package:neu_trade/features/review/domain/repositories/review_repository.dart';

class SubmitReviewParams extends Equatable {
  final int transactionId;
  final int stars;
  final String? content;

  const SubmitReviewParams({
    required this.transactionId,
    required this.stars,
    this.content,
  });

  @override
  List<Object?> get props => [transactionId, stars, content];
}

class SubmitReviewUsecase implements UseCase<ReviewEntity, SubmitReviewParams> {
  final ReviewRepository repository;

  const SubmitReviewUsecase(this.repository);

  @override
  Future<Either<Failure, ReviewEntity>> call(SubmitReviewParams params) async {
    return await repository.submitReview(
      transactionId: params.transactionId,
      stars: params.stars,
      content: params.content,
    );
  }
}
