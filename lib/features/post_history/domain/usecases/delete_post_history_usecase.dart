import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../repositories/post_history_repository.dart';

class DeletePostHistoryUsecase implements UseCase<Unit, int> {
  const DeletePostHistoryUsecase(this.repository);

  final PostHistoryRepository repository;

  @override
  Future<Either<Failure, Unit>> call(int postId) {
    return repository.deleteMyPost(postId: postId);
  }
}
