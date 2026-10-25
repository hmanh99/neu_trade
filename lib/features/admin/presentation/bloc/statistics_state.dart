import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/admin/domain/entities/circulation_stat_entity.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitialState extends StatisticsState {
  const StatisticsInitialState();
}

class StatisticsLoadingState extends StatisticsState {
  const StatisticsLoadingState();
}

class StatisticsLoadedState extends StatisticsState {
  final List<CirculationStatEntity> stats;

  const StatisticsLoadedState({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class StatisticsErrorState extends StatisticsState {
  final String message;

  const StatisticsErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
