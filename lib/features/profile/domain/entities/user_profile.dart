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
  });

  final String userId;
  final String studentId;
  final String fullName;
  final String email;
  final String phone;
  // Read-only values managed by the server, never by the profile form.
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
  ];
}
