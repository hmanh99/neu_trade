import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';
import 'package:neu_trade/features/admin/domain/repositories/admin_repository.dart';

class GetReportsParams {
  final String? status;
  const GetReportsParams({this.status});
}

class GetReportsUsecase implements UseCase<List<AdminReportEntity>, GetReportsParams> {
  final AdminRepository repository;

  GetReportsUsecase(this.repository);

  @override
  Future<Either<Failure, List<AdminReportEntity>>> call(GetReportsParams params) {
    return repository.getReports(status: params.status);
  }
}
