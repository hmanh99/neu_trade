import 'package:equatable/equatable.dart';

import 'address.dart';
import 'home_document_entity.dart';
import 'status.dart';

class HomePostEntity extends Equatable {
  const HomePostEntity({
    required this.id,
    required this.document,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.status,
    required this.createdAt,
    this.description,
    required this.address,
    this.imageUrls = const [],
  });

  final int id;
  final HomeDocumentEntity document;
  final String authorId, authorName, title;
  final Status status;
  final DateTime createdAt;
  final Address address;
  final String? description;
  final List<String> imageUrls;

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
    imageUrls,
  ];
}
