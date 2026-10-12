import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';
import 'package:neu_trade/features/home/domain/repositories/home_post_repository.dart';

class GetHomePostUsecase implements UseCase<HomePostEntity, GetHomePostParams> {
  const GetHomePostUsecase(this.repository);

  final HomePostRepository repository;

  @override
  Future<Either<Failure, HomePostEntity>> call(GetHomePostParams params) async {
    return await repository.getPost(postId: params.postId);
  }
}

class GetHomePostParams {
  final int postId;

  GetHomePostParams({required this.postId});
}
