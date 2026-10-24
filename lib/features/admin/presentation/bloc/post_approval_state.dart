import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_post_entity.dart';

abstract class PostApprovalState extends Equatable {
  const PostApprovalState();

  @override
  List<Object?> get props => [];
}

class PostApprovalInitialState extends PostApprovalState {
  const PostApprovalInitialState();
}

class PostApprovalLoadingState extends PostApprovalState {
  const PostApprovalLoadingState();
}

class PostApprovalLoadedState extends PostApprovalState {
  final List<AdminPostEntity> posts;
  final int? processingPostId;
  final String? successMessage;

  const PostApprovalLoadedState({
    required this.posts,
    this.processingPostId,
    this.successMessage,
  });

  PostApprovalLoadedState copyWith({
    List<AdminPostEntity>? posts,
    int? Function()? processingPostId,
    String? Function()? successMessage,
  }) {
    return PostApprovalLoadedState(
      posts: posts ?? this.posts,
      processingPostId:
          processingPostId != null ? processingPostId() : this.processingPostId,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [posts, processingPostId, successMessage];
}

class PostApprovalErrorState extends PostApprovalState {
  final String message;
  final List<AdminPostEntity> posts;

  const PostApprovalErrorState({required this.message, this.posts = const []});

  @override
  List<Object?> get props => [message, posts];
}
