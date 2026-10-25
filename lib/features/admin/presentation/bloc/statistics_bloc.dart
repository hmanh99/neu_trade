import 'package:bloc/bloc.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/admin/domain/usecases/get_circulation_stats_usecase.dart';
import 'package:neu_trade/features/admin/presentation/bloc/statistics_event.dart';
import 'package:neu_trade/features/admin/presentation/bloc/statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetCirculationStatsUsecase _getCirculationStats;

  StatisticsBloc({required GetCirculationStatsUsecase getCirculationStats})
    : _getCirculationStats = getCirculationStats,
      super(const StatisticsInitialState()) {
    on<StatisticsLoadEvent>((event, emit) async {
      if (state is StatisticsLoadingState) return;
      emit(const StatisticsLoadingState());
      final result = await _getCirculationStats(const NoParams());
      result.fold(
        (failure) => emit(StatisticsErrorState(message: failure.message)),
        (stats) => emit(StatisticsLoadedState(stats: stats)),
      );
    });
  }
}
