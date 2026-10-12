import 'package:equatable/equatable.dart';

import '../../domain/entities/create_upload_post_request.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class PostSubmissionRequested extends PostEvent {
  const PostSubmissionRequested({required this.input, required this.images});

  final CreatePostRequest input;
  final List<PostImageRequest> images;

  @override
  List<Object?> get props => [input, images];
}

class PostFormReset extends PostEvent {
  const PostFormReset();
}
