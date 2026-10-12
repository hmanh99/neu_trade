import 'package:neu_trade/features/home/domain/entities/address.dart';

import '../../domain/entities/status.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.transactionId,
    required super.postId,
    required super.buyerId,
    required super.buyerName,
    required super.sellerId,
    required super.sellerName,
    required super.postTitle,
    required super.price,
    required super.address,
    required super.orderTime,
    required super.expireTime,
    required super.status,
    super.note,
    super.imageUrls,
  });

  /// Parse from RPC responses or joined queries.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final tinDang = json['tin_dang'] is Map<String, dynamic>
        ? json['tin_dang'] as Map<String, dynamic>
        : null;

    final sellerId =
        json['nguoi_dang_id'] as String? ??
        tinDang?['nguoi_dang_id'] as String? ??
        '';
    final sellerName =
        json['ten_nguoi_ban'] as String? ??
        tinDang?['ho_ten_nguoi_dang'] as String? ??
        '';
    final postTitle =
        json['tieu_de_tin'] as String? ?? tinDang?['tieu_de'] as String? ?? '';
    final rawImages = json['hinh_anh'] ?? tinDang?['hinh_anh'];

    return TransactionModel(
      transactionId: (json['giaodich_id'] as num).toInt(),
      postId: (json['tindang_id'] as num).toInt(),
      buyerId: json['nguoi_mua_id'] as String? ?? '',
      buyerName: json['ten_nguoi_mua'] as String? ?? '',
      sellerId: sellerId,
      sellerName: sellerName,
      postTitle: postTitle,
      price: (json['tong_tien'] as num?)?.toDouble() ?? 0.0,
      address: Address.fromString(json['dia_chi'] as String? ?? ''),
      orderTime: json['thoi_gian_dat'] != null
          ? DateTime.parse(json['thoi_gian_dat'] as String)
          : DateTime.now(),
      expireTime: json['thoi_gian_het_han'] != null
          ? DateTime.parse(json['thoi_gian_het_han'] as String)
          : DateTime.now(),
      status: Status.fromString(
        json['trang_thai_gd'] as String? ?? 'DangGiuCho',
      ),
      note: json['note'] as String?,
      imageUrls: _parseImageUrls(rawImages),
    );
  }

  /// Keep backward compatibility
  factory TransactionModel.fromDetailJson(Map<String, dynamic> json) =>
      TransactionModel.fromJson(json);

  TransactionEntity toEntity() => TransactionEntity(
    transactionId: transactionId,
    postId: postId,
    buyerId: buyerId,
    buyerName: buyerName,
    sellerId: sellerId,
    sellerName: sellerName,
    postTitle: postTitle,
    price: price,
    address: address,
    orderTime: orderTime,
    expireTime: expireTime,
    status: status,
    note: note,
    imageUrls: imageUrls,
  );

  static List<String> _parseImageUrls(Object? value) {
    if (value == null) return const [];
    if (value is String) return [value];
    if (value is List) return value.whereType<String>().toList(growable: false);
    return const [];
  }
}
