import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:bloc/bloc.dart';
import 'package:neu_trade/features/auth/domain/entities/user_entities.dart';
import 'package:neu_trade/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/login_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/logout_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/watch_auth_state_use_case.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_event.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_state.dart';
import 'package:neu_trade/features/profile/domain/usecases/get_profile_use_case.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase _getCurrentUser;
  final LoginUseCase _login;
  final SignUpUseCase _signUp;
  final ForgotPasswordUseCase _forgotPassword;
  final LogoutUseCase _logout;
  final WatchAuthStateUseCase _watchAuthState;
  final GetProfileUseCase _getProfile;
  late final StreamSubscription<Either<Failure, UserEntity?>>
  _authStateSubscription;

  AuthBloc({
    required GetCurrentUserUseCase getCurrentUser,
    required LoginUseCase login,
    required SignUpUseCase signUp,
    required ForgotPasswordUseCase forgotPassword,
    required LogoutUseCase logout,
    required WatchAuthStateUseCase watchAuthState,
    required GetProfileUseCase getProfile,
  }) : _getCurrentUser = getCurrentUser,
       _login = login,
       _signUp = signUp,
       _forgotPassword = forgotPassword,
       _logout = logout,
       _watchAuthState = watchAuthState,
       _getProfile = getProfile,
       super(const AuthUnknownState()) {
    _authStateSubscription = _watchAuthState(NoParams()).listen((result) {
      result.fold(
        (failure) => add(const AuthSessionChanged(user: null)),
        (user) => add(AuthSessionChanged(user: user)),
      );
    });

    on<AuthSessionRestoreRequested>((event, emit) async {
      final result = await _getCurrentUser(NoParams());
      final user = result.fold((_) => null, (u) => u);
      if (user != null) {
        final isCompleted = await _checkProfileCompleted(user.id);
        emit(AuthLoginState(user: user, isProfileCompleted: isCompleted));
      } else {
        emit(const AuthInitialState());
      }
    });

    on<AuthSessionChanged>((event, emit) async {
      if (state is AuthLoadingState) return;

      if (event.user == null) {
        if (state is! AuthSignOutState) {
          emit(const AuthSignOutState());
        }
        return;
      }

      final user = event.user!;
      final currentState = state;
      if (currentState is AuthLoginState && currentState.user.id == user.id) {
        return;
      }
      final isCompleted = await _checkProfileCompleted(user.id);
      emit(AuthLoginState(user: user, isProfileCompleted: isCompleted));
    });

    on<AuthProfileCompletedEvent>((event, emit) {
      final currentState = state;
      if (currentState is AuthLoginState && !currentState.isProfileCompleted) {
        emit(
          AuthLoginState(
            user: currentState.user,
            isProfileCompleted: true,
          ),
        );
      }
    });

    // sign up
    on<AuthSignUpEvent>((event, emit) async {
      emit(const AuthLoadingState());
      final result = await _signUp(
        SignUpUseCaseParams(
          email: event.email,
          password: event.password,
        ),
      );
      result.fold(
        (failure) => emit(AuthErrorState(message: failure.message)),
        (user) => emit(AuthSignUpState(user: user)),
      );
    });

    // sign in
    on<AuthLoginEvent>((event, emit) async {
      emit(const AuthLoadingState());
      try {
        final result = await _login(
          LoginParams(email: event.email, password: event.password),
        );
        await result.fold(
          (failure) async => emit(AuthErrorState(message: failure.message)),
          (user) async {
            final isCompleted = await _checkProfileCompleted(user.id);
            emit(AuthLoginState(user: user, isProfileCompleted: isCompleted));
          },
        );
      } catch (e) {
        emit(AuthErrorState(message: e.toString()));
      }
    });

    //hande sign out
    on<AuthSignOutEvent>((event, emit) async {
      emit(const AuthLoadingState());
      try {
        final result = await _logout(NoParams());
        result.fold(
          (failure) => emit(AuthErrorState(message: failure.message)),
          (_) => emit(const AuthSignOutState()),
        );
      } catch (e) {
        emit(AuthErrorState(message: e.toString()));
      }
    });

    // forgot password
    on<AuthForgotPasswordEvent>((event, emit) async {
      emit(const AuthLoadingState());
      try {
        final result = await _forgotPassword(
          ForgotPasswordParams(email: event.email),
        );
        result.fold(
          (failure) => emit(AuthErrorState(message: failure.message)),
          (_) => emit(const AuthForgotPasswordSuccessState()),
        );
      } catch (e) {
        emit(AuthErrorState(message: e.toString()));
      }
    });
  }

  Future<bool> _checkProfileCompleted(String userId) async {
    final profileResult = await _getProfile(GetProfileParams(userId: userId));
    return profileResult.fold(
      (_) => false,
      (profile) => profile?.isCompleted ?? false,
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
