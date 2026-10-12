import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';
import 'package:neu_trade/features/transaction/domain/repositories/transaction_repository.dart';

class GetTransactionUsecase
    implements UseCase<TransactionEntity, GetTransactionUsecaseParam> {
  final TransactionRepository repository;

  GetTransactionUsecase({required this.repository});

  @override
  Future<Either<Failure, TransactionEntity>> call(
    GetTransactionUsecaseParam params,
  ) async {
    return await repository.getTransaction(transactionId: params.transactionId);
  }
}

class GetTransactionUsecaseParam {
  final int transactionId;

  GetTransactionUsecaseParam({required this.transactionId});
}
