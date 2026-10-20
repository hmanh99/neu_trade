import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.userId,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.reputationScore,
    this.cancelledOrderCount,
    required this.isCompleted,
  });

  final String userId;
  final String studentId;
  final String fullName;
  final String email;
  final String phone;
  final bool isCompleted;
  final num? reputationScore;
  final int? cancelledOrderCount;

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
  ];
}
