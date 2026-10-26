import 'package:equatable/equatable.dart';

import 'post_history_address.dart';
import 'post_history_category.dart';
import 'post_history_condition.dart';

class PostHistoryDocumentUpdateRequest extends Equatable {
  const PostHistoryDocumentUpdateRequest({
    required this.category,
    required this.name,
    required this.condition,
    required this.price,
    this.publicationYear,
    this.conditionNote,
  });

  final PostHistoryCategory category;
  final String name;
  final PostHistoryCondition condition;
  final String price;
  final int? publicationYear;
  final String? conditionNote;

  @override
  List<Object?> get props => [
    category,
    name,
    condition,
    price,
    publicationYear,
    conditionNote,
  ];
}

class PostHistoryUpdateRequest extends Equatable {
  const PostHistoryUpdateRequest({
    required this.document,
    required this.title,
    required this.address,
    this.description,
  });

  final PostHistoryDocumentUpdateRequest document;
  final String title;
  final PostHistoryAddress address;
  final String? description;

  @override
  List<Object?> get props => [document, title, address, description];
}
