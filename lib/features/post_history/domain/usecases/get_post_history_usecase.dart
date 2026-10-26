import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../entities/post_history_entity.dart';
import '../repositories/post_history_repository.dart';

class GetPostHistoryUsecase
    implements UseCase<List<PostHistoryEntity>, NoParams> {
  const GetPostHistoryUsecase(this.repository);

  final PostHistoryRepository repository;

  @override
  Future<Either<Failure, List<PostHistoryEntity>>> call(NoParams params) {
    return repository.getMyPosts();
  }
}
