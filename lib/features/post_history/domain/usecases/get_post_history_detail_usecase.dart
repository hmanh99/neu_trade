import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../entities/post_history_entity.dart';
import '../repositories/post_history_repository.dart';

class GetPostHistoryDetailUsecase
    implements UseCase<PostHistoryEntity, int> {
  const GetPostHistoryDetailUsecase(this.repository);

  final PostHistoryRepository repository;

  @override
  Future<Either<Failure, PostHistoryEntity>> call(int postId) {
    return repository.getMyPost(postId: postId);
  }
}
