import 'package:equatable/equatable.dart';
import '../../domain/entities/home_post_entity.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

class PostDetailLoadRequested extends PostDetailEvent {
  const PostDetailLoadRequested(this.postId);

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PostDetailInitialised extends PostDetailEvent {
  const PostDetailInitialised(this.post);

  final HomePostEntity post;

  @override
  List<Object?> get props => [post];
}

class PostDetailReserveSubmitted extends PostDetailEvent {
  const PostDetailReserveSubmitted({
    required this.postId,
    required this.meetingLocation,
  });

  final int postId;
  final String meetingLocation;

  @override
  List<Object?> get props => [postId, meetingLocation];
}

class PostDetailReportSubmitted extends PostDetailEvent {
  const PostDetailReportSubmitted({
    required this.postId,
    required this.reason,
    this.description,
  });

  final int postId;
  final String reason;
  final String? description;

  @override
  List<Object?> get props => [postId, reason, description];
}
