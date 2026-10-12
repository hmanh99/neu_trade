import 'package:bloc/bloc.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/home_post_entity.dart';
import '../../domain/usecases/get_home_posts_usecase.dart';
import 'home_post_event.dart';
import 'home_post_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetHomePostsUsecase getHomePosts})
    : _getHomePosts = getHomePosts,
      super(const HomeInitialState()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeFilterCategorySelected>(_onFilterCategorySelected);
    on<HomeSearchQueryChanged>(_onSearchQueryChanged);
  }

  final GetHomePostsUsecase _getHomePosts;

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());
    final result = await _getHomePosts(const NoParams());
    result.fold((failure) => emit(HomeFailureState(message: failure.message)), (
      posts,
    ) {
      emit(
        HomeLoadedState(
          allPosts: posts,
          filteredPosts: posts,
          selectedCategory: null,
          searchQuery: '',
        ),
      );
    });
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    final result = await _getHomePosts(const NoParams());
    result.fold(
      (failure) {
        if (currentState is! HomeLoadedState) {
          emit(HomeFailureState(message: failure.message));
        }
      },
      (posts) {
        if (currentState is HomeLoadedState) {
          final filtered = _filterPosts(
            posts,
            currentState.selectedCategory,
            currentState.searchQuery,
          );
          emit(currentState.copyWith(allPosts: posts, filteredPosts: filtered));
        } else {
          emit(
            HomeLoadedState(
              allPosts: posts,
              filteredPosts: posts,
              selectedCategory: null,
              searchQuery: '',
            ),
          );
        }
      },
    );
  }

  void _onFilterCategorySelected(
    HomeFilterCategorySelected event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoadedState) return;
    final loaded = state as HomeLoadedState;
    final newCategory = event.category;
    final filtered = _filterPosts(
      loaded.allPosts,
      newCategory,
      loaded.searchQuery,
    );
    emit(
      loaded.copyWith(
        selectedCategory: () => newCategory,
        filteredPosts: filtered,
      ),
    );
  }

  void _onSearchQueryChanged(
    HomeSearchQueryChanged event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoadedState) return;
    final loaded = state as HomeLoadedState;
    final query = event.query.trim().toLowerCase();
    final filtered = _filterPosts(
      loaded.allPosts,
      loaded.selectedCategory,
      query,
    );
    emit(loaded.copyWith(searchQuery: query, filteredPosts: filtered));
  }

  List<HomePostEntity> _filterPosts(
    List<HomePostEntity> posts,
    Category? category,
    String query,
  ) {
    return posts
        .where((post) {
          final matchesCategory =
              category == null || post.document.category == category;
          final matchesQuery =
              query.isEmpty ||
              post.title.toLowerCase().contains(query) ||
              post.document.name.toLowerCase().contains(query) ||
              (post.description != null &&
                  post.description!.toLowerCase().contains(query));
          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);
  }
}
