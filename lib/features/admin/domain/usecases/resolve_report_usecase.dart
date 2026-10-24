import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/admin/domain/repositories/admin_repository.dart';

class ResolveReportParams {
  final int reportId;
  final String status;

  const ResolveReportParams({required this.reportId, required this.status});
}

class ResolveReportUsecase implements UseCase<void, ResolveReportParams> {
  final AdminRepository repository;

  ResolveReportUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResolveReportParams params) {
    return repository.resolveReport(
      reportId: params.reportId,
      status: params.status,
    );
  }
}
