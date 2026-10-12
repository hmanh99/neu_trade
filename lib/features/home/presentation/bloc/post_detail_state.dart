import 'package:equatable/equatable.dart';
import '../../domain/entities/home_post_entity.dart';

abstract class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostDetailInitialState extends PostDetailState {
  const PostDetailInitialState();
}

class PostDetailLoadingState extends PostDetailState {
  const PostDetailLoadingState();
}

class PostDetailLoadedState extends PostDetailState {
  const PostDetailLoadedState(this.post);

  final HomePostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostDetailReservingState extends PostDetailState {
  const PostDetailReservingState(this.post);

  final HomePostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostDetailReserveSuccessState extends PostDetailState {
  const PostDetailReserveSuccessState({
    required this.post,
    required this.message,
  });

  final HomePostEntity post;
  final String message;

  @override
  List<Object?> get props => [post, message];
}

class PostDetailReportingState extends PostDetailState {
  const PostDetailReportingState(this.post);

  final HomePostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostDetailReportSuccessState extends PostDetailState {
  const PostDetailReportSuccessState({
    required this.post,
    required this.message,
  });

  final HomePostEntity post;
  final String message;

  @override
  List<Object?> get props => [post, message];
}

class PostDetailFailureState extends PostDetailState {
  const PostDetailFailureState({
    required this.message,
    this.post,
  });

  final String message;
  final HomePostEntity? post;

  @override
  List<Object?> get props => [message, post];
}
