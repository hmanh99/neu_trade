import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_document_entity.dart';

import './address.dart';
import './status.dart';

class AdminPostEntity extends Equatable {
  final int id;
  final AdminDocumentEntity document;
  final String authorId, authorName, title;
  final Status status;
  final DateTime createdAt;
  final Address address;
  final String? description;
  final List<String> imageUrls;

  const AdminPostEntity({
    required this.id,
    required this.document,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.address,
    required this.description,
    required this.imageUrls,
  });

  @override
  // TODO: implement props
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
