import 'package:neu_trade/features/post/domain/entities/category.dart';
import 'package:neu_trade/features/post/domain/entities/condition.dart';

import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.ownerId,
    required super.category,
    required super.name,
    required super.condition,
    required super.price,
    super.publicationYear,
    super.conditionNote,
  });
  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: (json['tailieu_id'] as num).toInt(),
    ownerId: json['sinhvien_id'] as String,
    category: Category.fromString(json['danhmuc'] as String),
    name: json['ten_sach'] as String,
    condition: Condition.fromString(json['do_moi'] as String),
    price: (json['gia_ban']) as double,
    publicationYear: (json['nam_xuat_ban'] as num?)?.toInt(),
    conditionNote: json['ghi_chu_tinh_trang'] as String?,
  );
  DocumentEntity toEntity() => DocumentEntity(
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
