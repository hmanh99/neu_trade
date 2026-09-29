import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:neu_trade/features/profile/data/models/profile_model.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';
import 'package:neu_trade/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.remoteDatasource});

  final ProfileRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, UserProfile?>> getProfile({
    required String userId,
  }) async {
    try {
      final profile = await remoteDatasource.getProfile(userId: userId);
      return Right(profile?.toEntity());
    } on ServerException catch (error) {
      return Left(Failure(error.message));
    } catch (_) {
      return Left(Failure('Không thể tải thông tin. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile({
    required UserProfile profile,
  }) async {
    try {
      return Right(
        await remoteDatasource.saveProfile(
          profile: ProfileModel.fromEntity(profile),
        ),
      );
    } on ServerException catch (error) {
      return Left(Failure(error.message));
    } catch (_) {
      return Left(Failure('Không thể lưu thông tin. Vui lòng thử lại.'));
    }
  }
}
