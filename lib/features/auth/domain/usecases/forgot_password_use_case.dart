import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ForgotPasswordUseCase implements UseCase<void, ForgotPasswordParams> {
  final AuthRepository repository;

  const ForgotPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    return await repository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams {
  final String email;

  ForgotPasswordParams({required this.email});
}
