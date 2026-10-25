import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';
import 'package:neu_trade/features/profile/domain/repositories/profile_repository.dart';

class GetProfileParams {
  const GetProfileParams({required this.userId});

  final String userId;
}

class GetProfileUseCase implements UseCase<UserProfileEntity?, GetProfileParams> {
  const GetProfileUseCase(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserProfileEntity?>> call(GetProfileParams params) {
    return repository.getProfile(userId: params.userId);
  }
}
