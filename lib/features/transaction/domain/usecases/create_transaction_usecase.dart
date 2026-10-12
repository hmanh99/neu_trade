import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';
import 'package:neu_trade/features/transaction/domain/repositories/transaction_repository.dart';

class CreateTransactionUsecase
    implements UseCase<TransactionEntity, CreateTransactionParams> {
  final TransactionRepository repository;

  const CreateTransactionUsecase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    CreateTransactionParams params,
  ) async {
    return await repository.createTransaction(
      postId: params.postId,
      note: params.note,
    );
  }
}

class CreateTransactionParams {
  final int postId;
  final String? note;

  const CreateTransactionParams({required this.postId, this.note});
}
