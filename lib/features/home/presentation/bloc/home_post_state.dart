import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/home_post_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeLoadedState extends HomeState {
  const HomeLoadedState({
    required this.allPosts,
    required this.filteredPosts,
    this.selectedCategory,
    this.searchQuery = '',
  });

  final List<HomePostEntity> allPosts;
  final List<HomePostEntity> filteredPosts;
  final Category? selectedCategory;
  final String searchQuery;

  HomeLoadedState copyWith({
    List<HomePostEntity>? allPosts,
    List<HomePostEntity>? filteredPosts,
    Category? Function()? selectedCategory,
    String? searchQuery,
  }) {
    return HomeLoadedState(
      allPosts: allPosts ?? this.allPosts,
      filteredPosts: filteredPosts ?? this.filteredPosts,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allPosts,
    filteredPosts,
    selectedCategory,
    searchQuery,
  ];
}

class HomeFailureState extends HomeState {
  const HomeFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
