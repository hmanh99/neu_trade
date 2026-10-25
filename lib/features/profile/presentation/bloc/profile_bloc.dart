import 'package:bloc/bloc.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';
import 'package:neu_trade/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:neu_trade/features/profile/domain/usecases/save_profile_use_case.dart';
import 'package:neu_trade/features/profile/domain/usecases/sign_out_profile_use_case.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_event.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.userId,
    required GetProfileUseCase getProfile,
    required SaveProfileUseCase saveProfile,
    required SignOutProfileUseCase signOutProfile,
  }) : _getProfile = getProfile,
       _saveProfile = saveProfile,
       _signOutProfile = signOutProfile,
       super(const ProfileInitialState()) {
    on<ProfileLoadEvent>((event, emit) async {
      if (_isBusy) return;
      emit(const ProfileLoadingState());
      final result = await _getProfile(GetProfileParams(userId: userId));
      result.fold(
        (failure) => emit(ProfileErrorState(message: failure.message)),
        (profile) => emit(ProfileLoadedState(profile: profile)),
      );
    });

    on<ProfileSaveEvent>((event, emit) async {
      if (_isBusy || state is ProfileSaveSuccessState) return;
      final currentAdmin = state is ProfileLoadedState
          ? (state as ProfileLoadedState).profile?.isAdmin ?? false
          : false;
      emit(const ProfileSavingState());
      final profile = UserProfileEntity(
        userId: userId,
        studentId: event.studentId,
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        isCompleted: event.isCompleted,
        isAdmin: currentAdmin,
      );
      final result = await _saveProfile(SaveProfileParams(profile: profile));
      result.fold(
        (failure) => emit(ProfileErrorState(message: failure.message)),
        (_) => emit(ProfileSaveSuccessState(profile: profile)),
      );
    });

    on<ProfileSignOutEvent>((event, emit) async {
      if (_isBusy) return;
      final currentProfile = state is ProfileLoadedState
          ? (state as ProfileLoadedState).profile
          : null;
      emit(ProfileSigningOutState(profile: currentProfile));
      final result = await _signOutProfile(const NoParams());
      result.fold(
        (failure) => emit(
          ProfileSignOutErrorState(
            profile: currentProfile,
            message: failure.message,
          ),
        ),
        (_) => emit(const ProfileSignedOutState()),
      );
    });
  }

  /// Fixed to the authenticated user for the lifetime of this screen's bloc.
  final String userId;
  final GetProfileUseCase _getProfile;
  final SaveProfileUseCase _saveProfile;
  final SignOutProfileUseCase _signOutProfile;

  bool get _isBusy =>
      state is ProfileLoadingState ||
      state is ProfileSavingState ||
      state is ProfileSigningOutState;
}
