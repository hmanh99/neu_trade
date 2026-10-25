import '../../../../core/error/exceptions.dart';
import '../../../../core/services/auth_services.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> signUp({
    required String email,
    required String password,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  UserModel? get currentUser;

  Stream<UserModel?> watchAuthState();

  Future<({bool isCompleted, bool isAdmin})> getUserFlags({
    required String userId,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDatasource {
  final AuthServices _authService;

  AuthRemoteDataSourceImpl(this._authService);

  @override
  UserModel? get currentUser {
    final user = _authService.user;
    if (user == null) return null;
    return UserModel.fromJson(user);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
      );
      return UserModel.fromJson(user);
    } on CustomAuthException {
      rethrow;
    } catch (e) {
      throw CustomAuthException(message: "Đã xảy ra lỗi");
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signIn(email: email, password: password);
      return UserModel.fromJson(user);
    } on CustomAuthException {
      rethrow;
    } catch (e) {
      throw CustomAuthException(message: "Đã xảy ra lỗi");
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authService.signOut();
    } on CustomAuthException {
      rethrow;
    } catch (e) {
      throw CustomAuthException(message: "Đã xảy ra lỗi");
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _authService.forgotPassword(email: email);
    } on CustomAuthException {
      rethrow;
    } catch (e) {
      throw CustomAuthException(message: "Đã xảy ra lỗi");
    }
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return _authService.authStateChanges.map((user) {
      if (user == null) return null;
      return UserModel.fromJson(user);
    });
  }

  @override
  Future<({bool isCompleted, bool isAdmin})> getUserFlags({
    required String userId,
  }) async {
    try {
      final data = await _authService.getUserFlags(userId: userId);
      return (
        isCompleted: (data?['is_completed'] as bool?) ?? false,
        isAdmin: (data?['is_admin'] as bool?) ?? false,
      );
    } catch (_) {
      return (isCompleted: false, isAdmin: false);
    }
  }
}
