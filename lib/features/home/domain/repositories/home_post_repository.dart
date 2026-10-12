import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';

import '../../../../core/error/failure.dart';

abstract interface class HomePostRepository {
  Future<Either<Failure, List<HomePostEntity>>> getPosts();
  Future<Either<Failure, HomePostEntity>> getPost({required int postId});
}