import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/review/domain/entities/rating_summary_entity.dart';
import 'package:neu_trade/features/review/domain/repositories/review_repository.dart';

class GetRatingSummaryParams extends Equatable {
  final String userId;

  const GetRatingSummaryParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetRatingSummaryUsecase
    implements UseCase<RatingSummaryEntity, GetRatingSummaryParams> {
  final ReviewRepository repository;

  const GetRatingSummaryUsecase(this.repository);

  @override
  Future<Either<Failure, RatingSummaryEntity>> call(
    GetRatingSummaryParams params,
  ) async {
    return await repository.getRatingSummary(targetUserId: params.userId);
  }
}
