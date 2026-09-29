import '../../domain/entities/post_entity.dart';
import 'document_model.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.document,
    required super.authorId,
    required super.authorName,
    required super.title,
    required super.status,
    required super.createdAt,
    super.description,
    super.address,
    super.imageUrl,
  });
  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: (json['tindang_id'] as num).toInt(),
    document: DocumentModel.fromJson(
      Map<String, dynamic>.from(json['tai_lieu'] as Map),
    ).toEntity(),
    authorId: json['nguoi_dang_id'] as String,
    authorName: json['ho_ten_nguoi_dang'] as String? ?? 'Sinh viên NEU',
    title: json['tieu_de'] as String,
    status: json['trang_thai_tin'] as String,
    createdAt: DateTime.parse(json['ngay_tao'] as String),
    description: json['noi_dung_mo_ta'] as String?,
    address: json['dia_chi'] as String?,
    imageUrl: json['hinh_anh'] as String?,
  );
  PostEntity toEntity() => PostEntity(
    id: id,
    document: document,
    authorId: authorId,
    authorName: authorName,
    title: title,
    status: status,
    createdAt: createdAt,
    description: description,
    address: address,
    imageUrl: imageUrl,
  );
}
