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
  });

  final String studentId;
  final String fullName;
  final String email;
  final String phone;

  @override
  List<Object?> get props => [studentId, fullName, email, phone];
}
