import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';
import 'package:neu_trade/features/transaction/domain/repositories/transaction_repository.dart';

class CompleteTransactionUsecase
    implements UseCase<TransactionEntity, CompleteTransactionParams> {
  final TransactionRepository repository;

  const CompleteTransactionUsecase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    CompleteTransactionParams params,
  ) async {
    return await repository.completeTransaction(
      transactionId: params.transactionId,
    );
  }
}

class CompleteTransactionParams {
  final int transactionId;

  const CompleteTransactionParams({required this.transactionId});
}
