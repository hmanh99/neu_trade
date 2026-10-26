import 'package:equatable/equatable.dart';

import '../../domain/entities/post_history_entity.dart';

abstract class PostHistoryDetailState extends Equatable {
  const PostHistoryDetailState();

  @override
  List<Object?> get props => [];
}

class PostHistoryDetailInitialState extends PostHistoryDetailState {
  const PostHistoryDetailInitialState();
}

class PostHistoryDetailLoadingState extends PostHistoryDetailState {
  const PostHistoryDetailLoadingState();
}

class PostHistoryDetailLoadedState extends PostHistoryDetailState {
  const PostHistoryDetailLoadedState({
    required this.post,
    this.isDeleting = false,
    this.actionError,
  });

  final PostHistoryEntity post;
  final bool isDeleting;
  final String? actionError;

  PostHistoryDetailLoadedState copyWith({
    PostHistoryEntity? post,
    bool? isDeleting,
    String? Function()? actionError,
  }) {
    return PostHistoryDetailLoadedState(
      post: post ?? this.post,
      isDeleting: isDeleting ?? this.isDeleting,
      actionError: actionError != null ? actionError() : this.actionError,
    );
  }

  @override
  List<Object?> get props => [post, isDeleting, actionError];
}

class PostHistoryDetailDeletedState extends PostHistoryDetailState {
  const PostHistoryDetailDeletedState({required this.postId});

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostHistoryDetailFailureState extends PostHistoryDetailState {
  const PostHistoryDetailFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
