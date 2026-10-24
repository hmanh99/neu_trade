import 'package:equatable/equatable.dart';

import 'category.dart';
import 'condition.dart';

class AdminDocumentEntity extends Equatable {
  const AdminDocumentEntity({
    required this.id,
    required this.ownerId,
    required this.category,
    required this.name,
    required this.condition,
    required this.price,
    this.publicationYear,
    this.conditionNote,
  });

  final int id;
  final String ownerId, name;
  final double price;
  final Category category;
  final Condition condition;
  final int? publicationYear;
  final String? conditionNote;

  @override
  List<Object?> get props => [
    id,
    ownerId,
    category,
    name,
    condition,
    price,
    publicationYear,
    conditionNote,
  ];
}
