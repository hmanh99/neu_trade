import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {
  const ProfileLoadEvent();
}

class ProfileSaveEvent extends ProfileEvent {
  const ProfileSaveEvent({
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isCompleted,
  });

  final String studentId;
  final String fullName;
  final String email;
  final String phone;
  final bool isCompleted;

  @override
  List<Object?> get props => [studentId, fullName, email, phone, isCompleted];
}

class ProfileSignOutEvent extends ProfileEvent {
  const ProfileSignOutEvent();
}
