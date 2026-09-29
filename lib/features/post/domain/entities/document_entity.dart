import 'package:equatable/equatable.dart';

class DocumentEntity extends Equatable {
  const DocumentEntity({
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
  final String ownerId, category, name, condition, price;
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
