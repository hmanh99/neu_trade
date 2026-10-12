import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/home/data/datasources/home_post_report_datasource.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_report_entity.dart';
import 'package:neu_trade/features/home/domain/repositories/home_post_report_repository.dart';

class HomePostReportRepositoryImpl implements HomePostReportRepository {
  final HomePostReportDatasource homePostReportDatasource;

  const HomePostReportRepositoryImpl({required this.homePostReportDatasource});

  @override
  Future<Either<Failure, HomePostReportEntity>> sendReport({
    required int postId,
    required String reason,
    String? description,
  }) async {
    try {
      final report = await homePostReportDatasource.sendReport(
        postId: postId,
        reason: reason,
        description: description,
      );
      return Right(report.toEntity());
    } on Exception catch (error) {
      return Left(Failure(error.toString()));
    }
  }
}
