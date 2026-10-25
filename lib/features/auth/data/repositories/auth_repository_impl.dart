import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:neu_trade/features/auth/domain/entities/user_entities.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    final user = remoteDatasource.currentUser;
    if (user == null) {
      return Left(Failure());
    }
    return Right(user.toEntity());
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDatasource.signUp(
        email: email,
        password: password,
      );
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDatasource.login(
        email: email,
        password: password,
      );
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      return Right(await remoteDatasource.logout());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      return Right(await remoteDatasource.forgotPassword(email: email));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, UserEntity?>> watchAuthState() {
    return remoteDatasource.watchAuthState().map((user) {
      if (user == null) {
        return Left(Failure());
      }
      return Right(user.toEntity());
    });
  }

  @override
  Future<Either<Failure, ({bool isCompleted, bool isAdmin})>> getUserFlags({
    required String userId,
  }) async {
    try {
      final flags = await remoteDatasource.getUserFlags(userId: userId);
      return Right(flags);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
