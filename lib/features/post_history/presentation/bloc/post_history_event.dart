import 'package:equatable/equatable.dart';

import '../../domain/entities/post_history_entity.dart';
import '../../domain/entities/post_history_status.dart';

abstract class PostHistoryEvent extends Equatable {
  const PostHistoryEvent();

  @override
  List<Object?> get props => [];
}

class PostHistoryLoadRequested extends PostHistoryEvent {
  const PostHistoryLoadRequested();
}

class PostHistoryRefreshRequested extends PostHistoryEvent {
  const PostHistoryRefreshRequested();
}

class PostHistoryStatusFilterSelected extends PostHistoryEvent {
  const PostHistoryStatusFilterSelected(this.status);

  final PostHistoryStatus? status;

  @override
  List<Object?> get props => [status];
}

class PostHistoryDeleteRequested extends PostHistoryEvent {
  const PostHistoryDeleteRequested(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostHistoryPostUpdated extends PostHistoryEvent {
  const PostHistoryPostUpdated(this.post);

  final PostHistoryEntity post;

  @override
  List<Object?> get props => [post];
}

class PostHistoryActionMessageCleared extends PostHistoryEvent {
  const PostHistoryActionMessageCleared();
}
