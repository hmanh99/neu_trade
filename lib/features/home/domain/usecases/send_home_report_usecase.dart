import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_report_entity.dart';
import 'package:neu_trade/features/home/domain/repositories/home_post_report_repository.dart';

class SendHomeReportUsecase
    implements UseCase<HomePostReportEntity, HomePostReportParams> {
  HomePostReportRepository repository;

  SendHomeReportUsecase(this.repository);

  @override
  Future<Either<Failure, HomePostReportEntity>> call(
    HomePostReportParams params,
  ) async {
    return repository.sendReport(
      postId: params.postId,
      reason: params.reason,
      description: params.description,
    );
  }
}

class HomePostReportParams {
  final int postId;
  final String reason;
  final String? description;

  const HomePostReportParams({
    required this.postId,
    required this.reason,
    this.description,
  });
}
