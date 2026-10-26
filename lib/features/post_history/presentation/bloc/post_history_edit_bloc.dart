import 'package:bloc/bloc.dart';

import '../../domain/entities/post_history_entity.dart';
import '../../domain/usecases/get_post_history_detail_usecase.dart';
import '../../domain/usecases/update_post_history_usecase.dart';
import 'post_history_edit_event.dart';
import 'post_history_edit_state.dart';

class PostHistoryEditBloc
    extends Bloc<PostHistoryEditEvent, PostHistoryEditState> {
  PostHistoryEditBloc({
    required GetPostHistoryDetailUsecase getPostHistoryDetail,
    required UpdatePostHistoryUsecase updatePostHistory,
    PostHistoryEntity? initialPost,
  }) : _getPostHistoryDetail = getPostHistoryDetail,
       _updatePostHistory = updatePostHistory,
       super(
         initialPost != null
             ? PostHistoryEditReadyState(initialPost: initialPost)
             : const PostHistoryEditLoadingState(),
       ) {
    on<PostHistoryEditLoadRequested>(_onLoadRequested);
    on<PostHistoryEditSubmitted>(_onSubmitted);
  }

  final GetPostHistoryDetailUsecase _getPostHistoryDetail;
  final UpdatePostHistoryUsecase _updatePostHistory;

  Future<void> _onLoadRequested(
    PostHistoryEditLoadRequested event,
    Emitter<PostHistoryEditState> emit,
  ) async {
    if (state is PostHistoryEditReadyState) return;
    emit(const PostHistoryEditLoadingState());
    final result = await _getPostHistoryDetail(event.postId);
    result.fold(
      (failure) => emit(PostHistoryEditLoadFailureState(message: failure.message)),
      (post) => emit(PostHistoryEditReadyState(initialPost: post)),
    );
  }

  Future<void> _onSubmitted(
    PostHistoryEditSubmitted event,
    Emitter<PostHistoryEditState> emit,
  ) async {
    if (state is! PostHistoryEditReadyState) return;
    final ready = state as PostHistoryEditReadyState;
    emit(ready.copyWith(isSubmitting: true, errorMessage: () => null));

    final result = await _updatePostHistory(
      UpdatePostHistoryParams(
        postId: event.postId,
        input: event.input,
        images: event.images,
      ),
    );

    result.fold(
      (failure) => emit(
        ready.copyWith(
          isSubmitting: false,
          errorMessage: () => failure.message,
        ),
      ),
      (updatedPost) => emit(PostHistoryEditSuccessState(updatedPost: updatedPost)),
    );
  }
}
