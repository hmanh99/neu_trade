import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';

class ProfileModel extends UserProfile {
  const ProfileModel({
    required super.userId,
    required super.studentId,
    required super.fullName,
    required super.email,
    required super.phone,
    super.reputationScore,
    super.cancelledOrderCount,
    required super.isCompleted,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['sinhvien_id'] as String,
      studentId: json['msv'] as String,
      fullName: json['ho_ten'] as String,
      email: json['email_neu'] as String,
      phone: json['so_dien_thoai'] as String,
      reputationScore: _readScore(json['diem_uy_tin']),
      cancelledOrderCount: (json['so_lan_huy_don'] as num?)?.toInt(),
      isCompleted: (json['is_completed'] as bool?) ?? false,
    );
  }

  factory ProfileModel.fromEntity(UserProfile profile) {
    return ProfileModel(
      userId: profile.userId,
      studentId: profile.studentId,
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      reputationScore: profile.reputationScore,
      cancelledOrderCount: profile.cancelledOrderCount,
      isCompleted: profile.isCompleted,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      studentId: studentId,
      fullName: fullName,
      email: email,
      phone: phone,
      reputationScore: reputationScore,
      cancelledOrderCount: cancelledOrderCount, isCompleted: isCompleted,
    );
  }

  static num? _readScore(Object? value) {
    if (value == null) return null;
    // Postgres numeric may be represented as a JSON number or decimal string.
    return value is num ? value : num.parse(value as String);
  }

  // Only user-editable fields belong in the upsert payload.
  Map<String, dynamic> toJson() => {
    'sinhvien_id': userId,
    'msv': studentId,
    'ho_ten': fullName,
    'email_neu': email,
    'so_dien_thoai': phone,
    'is_completed' : isCompleted
  };
}
