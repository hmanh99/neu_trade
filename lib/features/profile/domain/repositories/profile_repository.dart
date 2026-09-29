import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile?>> getProfile({required String userId});

  Future<Either<Failure, void>> saveProfile({required UserProfile profile});
}
