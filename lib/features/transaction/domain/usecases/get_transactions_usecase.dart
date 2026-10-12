import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';
import 'package:neu_trade/features/transaction/domain/repositories/transaction_repository.dart';

class GetTransactionsUsecase
    implements UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  GetTransactionsUsecase({required this.repository});

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) async {
    return await repository.getTransactions();
  }
}