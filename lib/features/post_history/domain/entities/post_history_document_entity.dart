import 'package:equatable/equatable.dart';

import 'post_history_category.dart';
import 'post_history_condition.dart';

class PostHistoryDocumentEntity extends Equatable {
  const PostHistoryDocumentEntity({
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
  final String ownerId;
  final String name;
  final double price;
  final PostHistoryCategory category;
  final PostHistoryCondition condition;
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
