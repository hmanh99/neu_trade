import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/admin/domain/entities/circulation_stat_entity.dart';
import 'package:neu_trade/features/admin/domain/repositories/admin_repository.dart';

class GetCirculationStatsUsecase
    implements UseCase<List<CirculationStatEntity>, NoParams> {
  final AdminRepository repository;

  const GetCirculationStatsUsecase(this.repository);

  @override
  Future<Either<Failure, List<CirculationStatEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getCirculationStats();
  }
}
