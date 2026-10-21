import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/services/statistics_services.dart';
import 'package:neu_trade/features/statistics/data/models/circulation_stat_model.dart';
import 'package:supabase/supabase.dart';

abstract class StatisticsRemoteDatasource {
  Future<List<CirculationStatModel>> getCirculationStats();
}

class StatisticsRemoteDatasourceImpl implements StatisticsRemoteDatasource {
  final StatisticsServices _statisticsServices;

  const StatisticsRemoteDatasourceImpl(this._statisticsServices);

  @override
  Future<List<CirculationStatModel>> getCirculationStats() async {
    try {
      final result = await _statisticsServices.getCirculationStats();
      return result.map(CirculationStatModel.fromJson).toList();
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }
}
