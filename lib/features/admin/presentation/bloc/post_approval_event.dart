import 'package:equatable/equatable.dart';

abstract class PostApprovalEvent extends Equatable {
  const PostApprovalEvent();

  @override
  List<Object?> get props => [];
}

class PostApprovalLoadEvent extends PostApprovalEvent {
  const PostApprovalLoadEvent();
}

class PostApprovalApproveEvent extends PostApprovalEvent {
  final int postId;

  const PostApprovalApproveEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostApprovalRejectEvent extends PostApprovalEvent {
  final int postId;

  const PostApprovalRejectEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}
