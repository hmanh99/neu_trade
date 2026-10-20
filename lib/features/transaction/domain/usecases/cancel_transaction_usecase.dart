import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';
import 'package:neu_trade/features/transaction/domain/repositories/transaction_repository.dart';

class CancelTransactionUsecase
    implements UseCase<TransactionEntity, CancelTransactionParams> {
  final TransactionRepository repository;

  const CancelTransactionUsecase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    CancelTransactionParams params,
  ) async {
    return await repository.cancelTransaction(
      transactionId: params.transactionId,
      reason: params.reason,
    );
  }
}

class CancelTransactionParams {
  final int transactionId;
  final String? reason;

  const CancelTransactionParams({
    required this.transactionId,
    this.reason,
  });
}
