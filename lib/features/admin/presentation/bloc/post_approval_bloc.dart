import 'package:bloc/bloc.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/admin/domain/usecases/approve_post_usecase.dart';
import 'package:neu_trade/features/admin/domain/usecases/get_pending_posts_usecase.dart';
import 'package:neu_trade/features/admin/domain/usecases/reject_post_usecase.dart';
import 'package:neu_trade/features/admin/presentation/bloc/post_approval_event.dart';
import 'package:neu_trade/features/admin/presentation/bloc/post_approval_state.dart';

class PostApprovalBloc extends Bloc<PostApprovalEvent, PostApprovalState> {
  final GetPendingPostsUsecase _getPendingPosts;
  final ApprovePostUsecase _approvePost;
  final RejectPostUsecase _rejectPost;

  PostApprovalBloc({
    required GetPendingPostsUsecase getPendingPosts,
    required ApprovePostUsecase approvePost,
    required RejectPostUsecase rejectPost,
  }) : _getPendingPosts = getPendingPosts,
       _approvePost = approvePost,
       _rejectPost = rejectPost,
       super(const PostApprovalInitialState()) {
    on<PostApprovalLoadEvent>((event, emit) async {
      emit(const PostApprovalLoadingState());
      final result = await _getPendingPosts(const NoParams());
      result.fold(
        (failure) => emit(PostApprovalErrorState(message: failure.message)),
        (posts) => emit(PostApprovalLoadedState(posts: posts)),
      );
    });

    on<PostApprovalApproveEvent>((event, emit) async {
      final currentLoaded = state is PostApprovalLoadedState
          ? (state as PostApprovalLoadedState)
          : null;
      if (currentLoaded != null && currentLoaded.processingPostId != null) {
        return;
      }

      if (currentLoaded != null) {
        emit(currentLoaded.copyWith(processingPostId: () => event.postId));
      }

      final result = await _approvePost(event.postId);
      result.fold(
        (failure) {
          if (currentLoaded != null) {
            emit(
              PostApprovalErrorState(
                message: failure.message,
                posts: currentLoaded.posts,
              ),
            );
          } else {
            emit(PostApprovalErrorState(message: failure.message));
          }
        },
        (_) {
          if (currentLoaded != null) {
            final updatedPosts = currentLoaded.posts
                .where((post) => post.id != event.postId)
                .toList();
            emit(
              PostApprovalLoadedState(
                posts: updatedPosts,
                successMessage: 'Đã duyệt bài đăng thành công.',
              ),
            );
          } else {
            add(const PostApprovalLoadEvent());
          }
        },
      );
    });

    on<PostApprovalRejectEvent>((event, emit) async {
      final currentLoaded = state is PostApprovalLoadedState
          ? (state as PostApprovalLoadedState)
          : null;
      if (currentLoaded != null && currentLoaded.processingPostId != null) {
        return;
      }

      if (currentLoaded != null) {
        emit(currentLoaded.copyWith(processingPostId: () => event.postId));
      }

      final result = await _rejectPost(event.postId);
      result.fold(
        (failure) {
          if (currentLoaded != null) {
            emit(
              PostApprovalErrorState(
                message: failure.message,
                posts: currentLoaded.posts,
              ),
            );
          } else {
            emit(PostApprovalErrorState(message: failure.message));
          }
        },
        (_) {
          if (currentLoaded != null) {
            final updatedPosts = currentLoaded.posts
                .where((post) => post.id != event.postId)
                .toList();
            emit(
              PostApprovalLoadedState(
                posts: updatedPosts,
                successMessage: 'Đã từ chối và xoá bài đăng thành công.',
              ),
            );
          } else {
            add(const PostApprovalLoadEvent());
          }
        },
      );
    });
  }
}
