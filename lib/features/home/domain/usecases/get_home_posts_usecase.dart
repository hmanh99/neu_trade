import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';
import 'package:neu_trade/features/home/domain/repositories/home_post_repository.dart';

class GetHomePostsUsecase implements UseCase<List<HomePostEntity>, NoParams> {
  const GetHomePostsUsecase(this.repository);

  final HomePostRepository repository;

  @override
  Future<Either<Failure, List<HomePostEntity>>> call(NoParams params) async {
    return await repository.getPosts();
  }
}