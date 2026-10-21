import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsLoadEvent extends StatisticsEvent {
  const StatisticsLoadEvent();
}
