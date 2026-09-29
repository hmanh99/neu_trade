import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) => repository.logout();
}
