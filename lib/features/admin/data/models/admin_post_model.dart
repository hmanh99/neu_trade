import 'package:neu_trade/features/admin/data/models/admin_document_model.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_post_entity.dart';
import 'package:neu_trade/features/admin/domain/entities/address.dart';
import 'package:neu_trade/features/admin/domain/entities/status.dart';


class AdminPostModel extends AdminPostEntity {
  const AdminPostModel({
    required super.id,
    required super.document,
    required super.authorId,
    required super.authorName,
    required super.title,
    required super.status,
    required super.createdAt,
    super.description,
    required super.address,
    required super.imageUrls,
  });

  factory AdminPostModel.fromJson(Map<String, dynamic> json) => AdminPostModel(
    id: (json['tindang_id'] as num).toInt(),
    document: AdminDocumentModel.fromJson(
      Map<String, dynamic>.from(json['tai_lieu'] as Map),
    ).toEntity(),
    authorId: json['nguoi_dang_id'] as String,
    authorName: json['ho_ten_nguoi_dang'] as String,
    title: json['tieu_de'] as String,
    status: Status.fromString(json['trang_thai_tin'] as String),
    createdAt: DateTime.parse(json['ngay_tao'] as String),
    description: json['noi_dung_mo_ta'] as String?,
    address: Address.fromString(json['dia_chi'] as String),
    imageUrls: _imageUrls(json['hinh_anh']),
  );

  AdminPostEntity toEntity() => AdminPostEntity(
    id: id,
    document: document,
    authorId: authorId,
    authorName: authorName,
    title: title,
    status: status,
    createdAt: createdAt,
    description: description,
    address: address,
    imageUrls: imageUrls,
  );

  static List<String> _imageUrls(Object? value) {
    if (value == null) return const [];
    if (value is String) return [value];
    if (value is List) return value.whereType<String>().toList(growable: false);
    throw const FormatException('Danh sách ảnh bài đăng không hợp lệ.');
  }
}
