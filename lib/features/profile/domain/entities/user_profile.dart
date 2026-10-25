import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  const UserProfileEntity({
    required this.userId,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.reputationScore,
    this.cancelledOrderCount,
    required this.isCompleted,
    this.isAdmin = false,
  });

  final String userId;
  final String studentId;
  final String fullName;
  final String email;
  final String phone;
  final bool isCompleted;
  final num? reputationScore;
  final int? cancelledOrderCount;
  final bool isAdmin;

  @override
  List<Object?> get props => [
    userId,
    studentId,
    fullName,
    email,
    phone,
    reputationScore,
    cancelledOrderCount,
    isCompleted,
    isAdmin,
  ];
}
