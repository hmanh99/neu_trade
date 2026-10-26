import 'package:equatable/equatable.dart';

import '../../domain/entities/post_history_entity.dart';

abstract class PostHistoryDetailEvent extends Equatable {
  const PostHistoryDetailEvent();

  @override
  List<Object?> get props => [];
}

class PostHistoryDetailLoadRequested extends PostHistoryDetailEvent {
  const PostHistoryDetailLoadRequested(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostHistoryDetailDeleteRequested extends PostHistoryDetailEvent {
  const PostHistoryDetailDeleteRequested(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostHistoryDetailUpdated extends PostHistoryDetailEvent {
  const PostHistoryDetailUpdated(this.post);

  final PostHistoryEntity post;

  @override
  List<Object?> get props => [post];
}
