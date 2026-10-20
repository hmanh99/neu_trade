import 'package:neu_trade/features/profile/domain/entities/user_public_stats.dart';

class UserPublicStatsModel extends UserPublicStats {
  const UserPublicStatsModel({
    required super.userId,
    required super.averageRating,
    required super.totalReviews,
    required super.cancelledOrderCount,
    required super.totalCompleted,
  });

  factory UserPublicStatsModel.fromJson(Map<String, dynamic> json) {
    return UserPublicStatsModel(
      userId: json['sinhvien_id'] as String? ?? '',
      averageRating: (json['diem_trung_binh'] as num?)?.toDouble() ?? 5.0,
      totalReviews: (json['tong_danh_gia'] as num?)?.toInt() ?? 0,
      cancelledOrderCount: (json['so_lan_huy_don'] as num?)?.toInt() ?? 0,
      totalCompleted: (json['tong_hoan_tat'] as num?)?.toInt() ?? 0,
    );
  }

  UserPublicStats toEntity() => UserPublicStats(
        userId: userId,
        averageRating: averageRating,
        totalReviews: totalReviews,
        cancelledOrderCount: cancelledOrderCount,
        totalCompleted: totalCompleted,
      );
}
