import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  const ProfileLoadedState({required this.profile});

  // Null means this account has not created a profile yet.
  final UserProfile? profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileSavingState extends ProfileState {
  const ProfileSavingState();
}

class ProfileSaveSuccessState extends ProfileState {
  const ProfileSaveSuccessState({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileErrorState extends ProfileState {
  const ProfileErrorState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
