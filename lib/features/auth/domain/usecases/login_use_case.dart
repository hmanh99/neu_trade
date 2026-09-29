import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/auth/domain/entities/user_entities.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
