import 'package:neu_trade/features/review/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.reviewId,
    required super.transactionId,
    required super.reviewerId,
    required super.targetUserId,
    required super.stars,
    super.content,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: (json['danhgia_id'] as num).toInt(),
      transactionId: (json['giaodich_id'] as num).toInt(),
      reviewerId: json['nguoi_danh_gia'] as String? ?? '',
      targetUserId: json['nguoi_nhan_danh_gia'] as String? ?? '',
      stars: (json['so_sao'] as num).toInt(),
      content: json['noi_dung'] as String?,
      createdAt: json['ngay_tao'] != null
          ? DateTime.parse(json['ngay_tao'] as String)
          : DateTime.now(),
    );
  }

  ReviewEntity toEntity() => ReviewEntity(
    reviewId: reviewId,
    transactionId: transactionId,
    reviewerId: reviewerId,
    targetUserId: targetUserId,
    stars: stars,
    content: content,
    createdAt: createdAt,
  );
}
