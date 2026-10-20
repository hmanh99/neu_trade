import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';

abstract interface class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();

  Future<Either<Failure, TransactionEntity>> getTransaction({
    required int transactionId,
  });

  Future<Either<Failure, TransactionEntity>> createTransaction({
    required int postId,
    String? note,
  });

  Future<Either<Failure, TransactionEntity>> completeTransaction({
    required int transactionId,
  });

  Future<Either<Failure, TransactionEntity>> cancelTransaction({
    required int transactionId,
    String? reason,
  });
}
