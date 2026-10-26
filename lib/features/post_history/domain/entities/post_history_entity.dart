import 'package:equatable/equatable.dart';

import 'post_history_address.dart';
import 'post_history_document_entity.dart';
import 'post_history_status.dart';

class PostHistoryEntity extends Equatable {
  const PostHistoryEntity({
    required this.id,
    required this.document,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.address,
    this.description,
    this.imageUrls = const [],
  });

  final int id;
  final PostHistoryDocumentEntity document;
  final String authorId;
  final String authorName;
  final String title;
  final PostHistoryStatus status;
  final DateTime createdAt;
  final PostHistoryAddress address;
  final String? description;
  final List<String> imageUrls;

  bool get canEdit =>
      status == PostHistoryStatus.daAn ||
      status == PostHistoryStatus.dangHienThi;

  bool get canDelete =>
      status == PostHistoryStatus.daAn ||
      status == PostHistoryStatus.dangHienThi;

  @override
  List<Object?> get props => [
    id,
    document,
    authorId,
    authorName,
    title,
    status,
    createdAt,
    address,
    description,
    imageUrls,
  ];
}
