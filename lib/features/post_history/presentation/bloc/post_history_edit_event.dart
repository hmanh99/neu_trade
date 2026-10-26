import 'package:equatable/equatable.dart';

import '../../domain/entities/post_history_image_input.dart';
import '../../domain/entities/post_history_update_request.dart';

abstract class PostHistoryEditEvent extends Equatable {
  const PostHistoryEditEvent();

  @override
  List<Object?> get props => [];
}

class PostHistoryEditLoadRequested extends PostHistoryEditEvent {
  const PostHistoryEditLoadRequested(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostHistoryEditSubmitted extends PostHistoryEditEvent {
  const PostHistoryEditSubmitted({
    required this.postId,
    required this.input,
    required this.images,
  });

  final int postId;
  final PostHistoryUpdateRequest input;
  final List<PostHistoryImageInput> images;

  @override
  List<Object?> get props => [postId, input, images];
}
