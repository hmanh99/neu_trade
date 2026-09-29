import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/auth/domain/entities/user_entities.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
