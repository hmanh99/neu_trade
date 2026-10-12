import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/home/data/datasources/home_post_remote_datasource.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';
import 'package:neu_trade/features/home/domain/repositories/home_post_repository.dart';

class HomePostRepositoryImpl implements HomePostRepository {
  final HomePostRemoteDatasource homePostRemoteDatasource;

  HomePostRepositoryImpl({required this.homePostRemoteDatasource});

  @override
  Future<Either<Failure, HomePostEntity>> getPost({required int postId}) async {
    try {
      final post = await homePostRemoteDatasource.getPost(postId: postId);
      return Right(post.toEntity());
    } on Exception {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<HomePostEntity>>> getPosts() async {
    try {
      final posts = await homePostRemoteDatasource.getPosts();
      return Right(posts.map((post) => post.toEntity()).toList());
    } on Exception {
      return Left(Failure());
    }
  }
}
