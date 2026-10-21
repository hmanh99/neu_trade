import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/statistics/data/datasources/statistics_remote_datasource.dart';
import 'package:neu_trade/features/statistics/domain/entities/circulation_stat_entity.dart';
import 'package:neu_trade/features/statistics/domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDatasource remoteDatasource;

  const StatisticsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<CirculationStatEntity>>>
  getCirculationStats() async {
    try {
      final models = await remoteDatasource.getCirculationStats();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
