import 'package:equatable/equatable.dart';

import '../../domain/entities/post_history_entity.dart';
import '../../domain/entities/post_history_status.dart';

class PostHistoryActionMessage extends Equatable {
  const PostHistoryActionMessage({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  List<Object?> get props => [message, isError];
}

abstract class PostHistoryState extends Equatable {
  const PostHistoryState();

  @override
  List<Object?> get props => [];
}

class PostHistoryInitialState extends PostHistoryState {
  const PostHistoryInitialState();
}

class PostHistoryLoadingState extends PostHistoryState {
  const PostHistoryLoadingState();
}

class PostHistoryLoadedState extends PostHistoryState {
  const PostHistoryLoadedState({
    required this.allPosts,
    required this.filteredPosts,
    this.selectedStatus,
    this.deletingPostId,
    this.actionMessage,
  });

  final List<PostHistoryEntity> allPosts;
  final List<PostHistoryEntity> filteredPosts;
  final PostHistoryStatus? selectedStatus;
  final int? deletingPostId;
  final PostHistoryActionMessage? actionMessage;

  int countByStatus(PostHistoryStatus status) {
    return allPosts.where((post) => post.status == status).length;
  }

  PostHistoryLoadedState copyWith({
    List<PostHistoryEntity>? allPosts,
    List<PostHistoryEntity>? filteredPosts,
    PostHistoryStatus? Function()? selectedStatus,
    int? Function()? deletingPostId,
    PostHistoryActionMessage? Function()? actionMessage,
  }) {
    return PostHistoryLoadedState(
      allPosts: allPosts ?? this.allPosts,
      filteredPosts: filteredPosts ?? this.filteredPosts,
      selectedStatus: selectedStatus != null
          ? selectedStatus()
          : this.selectedStatus,
      deletingPostId: deletingPostId != null
          ? deletingPostId()
          : this.deletingPostId,
      actionMessage: actionMessage != null
          ? actionMessage()
          : this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    allPosts,
    filteredPosts,
    selectedStatus,
    deletingPostId,
    actionMessage,
  ];
}

class PostHistoryFailureState extends PostHistoryState {
  const PostHistoryFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
