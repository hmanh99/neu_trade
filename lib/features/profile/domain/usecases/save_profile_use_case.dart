import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';
import 'package:neu_trade/features/profile/domain/repositories/profile_repository.dart';

class SaveProfileParams {
  const SaveProfileParams({required this.profile});

  final UserProfile profile;
}

class SaveProfileUseCase implements UseCase<void, SaveProfileParams> {
  const SaveProfileUseCase(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(SaveProfileParams params) {
    return repository.saveProfile(profile: params.profile);
  }
}
