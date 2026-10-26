import '../../domain/entities/post_history_category.dart';
import '../../domain/entities/post_history_condition.dart';
import '../../domain/entities/post_history_document_entity.dart';

class PostHistoryDocumentModel extends PostHistoryDocumentEntity {
  const PostHistoryDocumentModel({
    required super.id,
    required super.ownerId,
    required super.category,
    required super.name,
    required super.condition,
    required super.price,
    super.publicationYear,
    super.conditionNote,
  });

  factory PostHistoryDocumentModel.fromJson(Map<String, dynamic> json) =>
      PostHistoryDocumentModel(
        id: (json['tailieu_id'] as num).toInt(),
        ownerId: json['sinhvien_id'] as String,
        category: PostHistoryCategory.fromString(json['danhmuc'] as String),
        name: json['ten_sach'] as String,
        condition: PostHistoryCondition.fromString(json['do_moi'] as String),
        price: (json['gia_ban'] as num).toDouble(),
        publicationYear: (json['nam_xuat_ban'] as num?)?.toInt(),
        conditionNote: json['ghi_chu_tinh_trang'] as String?,
      );

  PostHistoryDocumentEntity toEntity() => PostHistoryDocumentEntity(
    id: id,
    ownerId: ownerId,
    category: category,
    name: name,
    condition: condition,
    price: price,
    publicationYear: publicationYear,
    conditionNote: conditionNote,
  );
}
