import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/auth/domain/entities/user_entities.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Session chưa xác định (đang restore từ Firebase / repositories).
class AuthUnknownState extends AuthState {
  const AuthUnknownState();
}

/// User đã đăng nhập (dùng cho redirect / guard).
abstract class AuthAuthenticatedState extends AuthState {
  const AuthAuthenticatedState();
}

//     Initial (guest — ví dụ welcome / onboarding entry)

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

//     Loading

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

//     Sign-in / Sign-up success

class AuthLoginState extends AuthAuthenticatedState {
  final UserEntity user;
  final bool isProfileCompleted;
  final bool isAdmin;

  const AuthLoginState({
    required this.user,
    this.isProfileCompleted = false,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [user, isProfileCompleted, isAdmin];
}

/// Account creation succeeded. This is deliberately not an authenticated
/// state: the user must sign in from the login screen after registering.
class AuthSignUpState extends AuthState {
  final UserEntity user;

  const AuthSignUpState({required this.user});

  @override
  List<Object?> get props => [user];
}

//     Forgot password

class AuthForgotPasswordSuccessState extends AuthState {
  const AuthForgotPasswordSuccessState();
}

//     Sign-out

class AuthSignOutState extends AuthState {
  const AuthSignOutState();
}

//     Error

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
