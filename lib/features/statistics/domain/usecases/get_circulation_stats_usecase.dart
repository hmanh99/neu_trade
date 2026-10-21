import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/statistics/domain/entities/circulation_stat_entity.dart';
import 'package:neu_trade/features/statistics/domain/repositories/statistics_repository.dart';

class GetCirculationStatsUsecase
    implements UseCase<List<CirculationStatEntity>, NoParams> {
  final StatisticsRepository repository;

  const GetCirculationStatsUsecase(this.repository);

  @override
  Future<Either<Failure, List<CirculationStatEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getCirculationStats();
  }
}
