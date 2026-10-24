import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/admin/domain/repositories/admin_repository.dart';

class ApprovePostUsecase implements UseCase<void, int> {
  final AdminRepository repository;

  ApprovePostUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(int postId) {
    return repository.approvePost(postId);
  }
}
