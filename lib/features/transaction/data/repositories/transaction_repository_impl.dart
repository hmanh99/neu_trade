import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource remoteDatasource;

  TransactionRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required int postId,
    String? note,
  }) async {
    try {
      final result = await remoteDatasource.createTransaction(
        postId: postId,
        note: note,
      );
      return Right(result.toEntity());
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction({
    required int transactionId,
  }) async {
    try {
      final result = await remoteDatasource.getTransaction(
        transactionId: transactionId,
      );
      return Right(result.toEntity());
    } on Exception {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final results = await remoteDatasource.getTransactions();
      return Right(
        results.map((model) => model.toEntity()).toList(),
      );
    } on Exception {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> completeTransaction({
    required int transactionId,
  }) async {
    try {
      final result = await remoteDatasource.completeTransaction(
        transactionId: transactionId,
      );
      return Right(result.toEntity());
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
