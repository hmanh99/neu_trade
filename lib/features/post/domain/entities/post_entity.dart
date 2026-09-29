import 'package:equatable/equatable.dart';

import 'document_entity.dart';

class PostEntity extends Equatable {
  const PostEntity({
    required this.id,
    required this.document,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.status,
    required this.createdAt,
    this.description,
    this.address,
    this.imageUrl,
  });
  final int id;
  final DocumentEntity document;
  final String authorId, authorName, title, status;
  final DateTime createdAt;
  final String? description, address, imageUrl;
  @override
  List<Object?> get props => [
    id,
    document,
    authorId,
    authorName,
    title,
    status,
    createdAt,
    description,
    address,
    imageUrl,
  ];
}
