import 'package:bloc/bloc.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';
import 'package:neu_trade/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:neu_trade/features/profile/domain/usecases/save_profile_use_case.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_event.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.userId,
    required GetProfileUseCase getProfile,
    required SaveProfileUseCase saveProfile,
  }) : _getProfile = getProfile,
       _saveProfile = saveProfile,
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
      final profile = UserProfile(
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
  }

  /// Fixed to the authenticated user for the lifetime of this screen's bloc.
  final String userId;
  final GetProfileUseCase _getProfile;
  final SaveProfileUseCase _saveProfile;

  bool get _isBusy =>
      state is ProfileLoadingState || state is ProfileSavingState;
}
