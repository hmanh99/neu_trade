import 'package:equatable/equatable.dart';

import '../../domain/entities/upload_post_entity.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitialState extends PostState {
  const PostInitialState();
}

class PostSubmittingState extends PostState {
  const PostSubmittingState();
}

class PostSubmissionSuccessState extends PostState {
  const PostSubmissionSuccessState(this.post);

  final UploadPostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostSubmissionFailureState extends PostState {
  const PostSubmissionFailureState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message,];
}
