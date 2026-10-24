import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/admin/domain/repositories/admin_repository.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_post_entity.dart';

class GetPendingPostsUsecase implements UseCase<List<AdminPostEntity>, NoParams> {
  final AdminRepository repository;

  GetPendingPostsUsecase(this.repository);

  @override
  Future<Either<Failure, List<AdminPostEntity>>> call(NoParams params) {
    return repository.getPendingPosts();
  }
}
