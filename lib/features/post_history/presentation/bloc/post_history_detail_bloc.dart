import 'package:bloc/bloc.dart';

import '../../domain/entities/post_history_entity.dart';
import '../../domain/usecases/delete_post_history_usecase.dart';
import '../../domain/usecases/get_post_history_detail_usecase.dart';
import 'post_history_detail_event.dart';
import 'post_history_detail_state.dart';

class PostHistoryDetailBloc
    extends Bloc<PostHistoryDetailEvent, PostHistoryDetailState> {
  PostHistoryDetailBloc({
    required GetPostHistoryDetailUsecase getPostHistoryDetail,
    required DeletePostHistoryUsecase deletePostHistory,
    PostHistoryEntity? initialPost,
  }) : _getPostHistoryDetail = getPostHistoryDetail,
       _deletePostHistory = deletePostHistory,
       super(
         initialPost != null
             ? PostHistoryDetailLoadedState(post: initialPost)
             : const PostHistoryDetailInitialState(),
       ) {
    on<PostHistoryDetailLoadRequested>(_onLoadRequested);
    on<PostHistoryDetailDeleteRequested>(_onDeleteRequested);
    on<PostHistoryDetailUpdated>(_onUpdated);
  }

  final GetPostHistoryDetailUsecase _getPostHistoryDetail;
  final DeletePostHistoryUsecase _deletePostHistory;

  Future<void> _onLoadRequested(
    PostHistoryDetailLoadRequested event,
    Emitter<PostHistoryDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostHistoryDetailLoadedState) {
      emit(const PostHistoryDetailLoadingState());
    }
    final result = await _getPostHistoryDetail(event.postId);
    result.fold(
      (failure) {
        if (current is! PostHistoryDetailLoadedState) {
          emit(PostHistoryDetailFailureState(message: failure.message));
        }
      },
      (post) => emit(PostHistoryDetailLoadedState(post: post)),
    );
  }

  Future<void> _onDeleteRequested(
    PostHistoryDetailDeleteRequested event,
    Emitter<PostHistoryDetailState> emit,
  ) async {
    if (state is! PostHistoryDetailLoadedState) return;
    final loaded = state as PostHistoryDetailLoadedState;
    emit(loaded.copyWith(isDeleting: true, actionError: () => null));

    final result = await _deletePostHistory(event.postId);
    result.fold(
      (failure) => emit(
        loaded.copyWith(
          isDeleting: false,
          actionError: () => failure.message,
        ),
      ),
      (_) => emit(PostHistoryDetailDeletedState(postId: event.postId)),
    );
  }

  void _onUpdated(
    PostHistoryDetailUpdated event,
    Emitter<PostHistoryDetailState> emit,
  ) {
    emit(PostHistoryDetailLoadedState(post: event.post));
  }
}
