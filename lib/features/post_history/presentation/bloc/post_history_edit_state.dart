import 'package:equatable/equatable.dart';

import '../../domain/entities/post_history_entity.dart';

abstract class PostHistoryEditState extends Equatable {
  const PostHistoryEditState();

  @override
  List<Object?> get props => [];
}

class PostHistoryEditLoadingState extends PostHistoryEditState {
  const PostHistoryEditLoadingState();
}

class PostHistoryEditLoadFailureState extends PostHistoryEditState {
  const PostHistoryEditLoadFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class PostHistoryEditReadyState extends PostHistoryEditState {
  const PostHistoryEditReadyState({
    required this.initialPost,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final PostHistoryEntity initialPost;
  final bool isSubmitting;
  final String? errorMessage;

  PostHistoryEditReadyState copyWith({
    PostHistoryEntity? initialPost,
    bool? isSubmitting,
    String? Function()? errorMessage,
  }) {
    return PostHistoryEditReadyState(
      initialPost: initialPost ?? this.initialPost,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [initialPost, isSubmitting, errorMessage];
}

class PostHistoryEditSuccessState extends PostHistoryEditState {
  const PostHistoryEditSuccessState({required this.updatedPost});

  final PostHistoryEntity updatedPost;

  @override
  List<Object?> get props => [updatedPost];
}
