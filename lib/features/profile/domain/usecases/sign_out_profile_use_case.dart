import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/profile/domain/repositories/profile_repository.dart';

class SignOutProfileUseCase implements UseCase<void, NoParams> {
  const SignOutProfileUseCase(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
