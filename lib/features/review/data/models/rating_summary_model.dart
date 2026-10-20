import 'package:neu_trade/features/review/domain/entities/rating_summary_entity.dart';

class RatingSummaryModel extends RatingSummaryEntity {
  const RatingSummaryModel({
    required super.userId,
    required super.averageRating,
    required super.totalReviews,
  });

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    return RatingSummaryModel(
      userId: json['sinhvien_id'] as String? ?? '',
      averageRating: (json['diem_trung_binh'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['tong_danh_gia'] as num?)?.toInt() ?? 0,
    );
  }

  RatingSummaryEntity toEntity() => RatingSummaryEntity(
    userId: userId,
    averageRating: averageRating,
    totalReviews: totalReviews,
  );
}
