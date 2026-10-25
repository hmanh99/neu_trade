import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';

class GetUserFlagsParams {
  const GetUserFlagsParams({required this.userId});

  final String userId;
}

class GetUserFlagsUseCase
    implements UseCase<({bool isCompleted, bool isAdmin}), GetUserFlagsParams> {
  const GetUserFlagsUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, ({bool isCompleted, bool isAdmin})>> call(
    GetUserFlagsParams params,
  ) {
    return repository.getUserFlags(userId: params.userId);
  }
}
