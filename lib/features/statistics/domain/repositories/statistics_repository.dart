import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/statistics/domain/entities/circulation_stat_entity.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, List<CirculationStatEntity>>> getCirculationStats();
}
