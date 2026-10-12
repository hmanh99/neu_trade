import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class HomeFilterCategorySelected extends HomeEvent {
  const HomeFilterCategorySelected(this.category);

  final Category? category;

  @override
  List<Object?> get props => [category];
}

class HomeSearchQueryChanged extends HomeEvent {
  const HomeSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
