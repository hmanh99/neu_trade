import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/auth/domain/entities/user_entities.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';

class SignUpUseCaseParams {
  final String email;
  final String password;

  const SignUpUseCaseParams({
    required this.email,
    required this.password,
  });
}

class SignUpUseCase implements UseCase<UserEntity, SignUpUseCaseParams> {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpUseCaseParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
    );
  }
}
