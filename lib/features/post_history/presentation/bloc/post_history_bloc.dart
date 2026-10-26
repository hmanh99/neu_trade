import 'package:bloc/bloc.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../../domain/entities/post_history_entity.dart';
import '../../domain/entities/post_history_status.dart';
import '../../domain/usecases/delete_post_history_usecase.dart';
import '../../domain/usecases/get_post_history_usecase.dart';
import 'post_history_event.dart';
import 'post_history_state.dart';

class PostHistoryBloc extends Bloc<PostHistoryEvent, PostHistoryState> {
  PostHistoryBloc({
    required GetPostHistoryUsecase getPostHistory,
    required DeletePostHistoryUsecase deletePostHistory,
  }) : _getPostHistory = getPostHistory,
       _deletePostHistory = deletePostHistory,
       super(const PostHistoryInitialState()) {
    on<PostHistoryLoadRequested>(_onLoadRequested);
    on<PostHistoryRefreshRequested>(_onRefreshRequested);
    on<PostHistoryStatusFilterSelected>(_onStatusFilterSelected);
    on<PostHistoryDeleteRequested>(_onDeleteRequested);
    on<PostHistoryPostUpdated>(_onPostUpdated);
    on<PostHistoryActionMessageCleared>(_onActionMessageCleared);
  }

  final GetPostHistoryUsecase _getPostHistory;
  final DeletePostHistoryUsecase _deletePostHistory;

  Future<void> _onLoadRequested(
    PostHistoryLoadRequested event,
    Emitter<PostHistoryState> emit,
  ) async {
    emit(const PostHistoryLoadingState());
    final result = await _getPostHistory(const NoParams());
    result.fold(
      (failure) => emit(PostHistoryFailureState(message: failure.message)),
      (posts) => emit(
        PostHistoryLoadedState(
          allPosts: posts,
          filteredPosts: posts,
          selectedStatus: null,
        ),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    PostHistoryRefreshRequested event,
    Emitter<PostHistoryState> emit,
  ) async {
    final currentState = state;
    final result = await _getPostHistory(const NoParams());
    result.fold(
      (failure) {
        if (currentState is! PostHistoryLoadedState) {
          emit(PostHistoryFailureState(message: failure.message));
        }
      },
      (posts) {
        if (currentState is PostHistoryLoadedState) {
          final filtered = _filterPosts(posts, currentState.selectedStatus);
          emit(
            currentState.copyWith(
              allPosts: posts,
              filteredPosts: filtered,
              deletingPostId: () => null,
            ),
          );
        } else {
          emit(
            PostHistoryLoadedState(
              allPosts: posts,
              filteredPosts: posts,
              selectedStatus: null,
            ),
          );
        }
      },
    );
  }

  void _onStatusFilterSelected(
    PostHistoryStatusFilterSelected event,
    Emitter<PostHistoryState> emit,
  ) {
    if (state is! PostHistoryLoadedState) return;
    final loaded = state as PostHistoryLoadedState;
    final filtered = _filterPosts(loaded.allPosts, event.status);
    emit(
      loaded.copyWith(
        selectedStatus: () => event.status,
        filteredPosts: filtered,
      ),
    );
  }

  Future<void> _onDeleteRequested(
    PostHistoryDeleteRequested event,
    Emitter<PostHistoryState> emit,
  ) async {
    if (state is! PostHistoryLoadedState) return;
    final loaded = state as PostHistoryLoadedState;
    emit(
      loaded.copyWith(
        deletingPostId: () => event.postId,
        actionMessage: () => null,
      ),
    );

    final result = await _deletePostHistory(event.postId);
    if (state is! PostHistoryLoadedState) return;
    final currentLoaded = state as PostHistoryLoadedState;

    result.fold(
      (failure) {
        emit(
          currentLoaded.copyWith(
            deletingPostId: () => null,
            actionMessage: () => PostHistoryActionMessage(
              message: failure.message,
              isError: true,
            ),
          ),
        );
      },
      (_) {
        final updatedAll = currentLoaded.allPosts
            .where((post) => post.id != event.postId)
            .toList(growable: false);
        final updatedFiltered = _filterPosts(
          updatedAll,
          currentLoaded.selectedStatus,
        );
        emit(
          currentLoaded.copyWith(
            allPosts: updatedAll,
            filteredPosts: updatedFiltered,
            deletingPostId: () => null,
            actionMessage: () => const PostHistoryActionMessage(
              message: 'Đã xoá bài đăng thành công.',
              isError: false,
            ),
          ),
        );
      },
    );
  }

  void _onPostUpdated(
    PostHistoryPostUpdated event,
    Emitter<PostHistoryState> emit,
  ) {
    if (state is! PostHistoryLoadedState) return;
    final loaded = state as PostHistoryLoadedState;
    final updatedAll = loaded.allPosts
        .map((post) => post.id == event.post.id ? event.post : post)
        .toList(growable: false);
    final updatedFiltered = _filterPosts(updatedAll, loaded.selectedStatus);
    emit(
      loaded.copyWith(
        allPosts: updatedAll,
        filteredPosts: updatedFiltered,
      ),
    );
  }

  void _onActionMessageCleared(
    PostHistoryActionMessageCleared event,
    Emitter<PostHistoryState> emit,
  ) {
    if (state is! PostHistoryLoadedState) return;
    final loaded = state as PostHistoryLoadedState;
    emit(loaded.copyWith(actionMessage: () => null));
  }

  List<PostHistoryEntity> _filterPosts(
    List<PostHistoryEntity> posts,
    PostHistoryStatus? status,
  ) {
    if (status == null) return posts;
    return posts
        .where((post) => post.status == status)
        .toList(growable: false);
  }
}
