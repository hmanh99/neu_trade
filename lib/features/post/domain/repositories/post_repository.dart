import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';

import '../entities/create_post_request.dart';
import '../entities/post_entity.dart';

abstract interface class PostRepository {
  Future<Either<Failure, PostEntity>> createPost({
    required String requestId,
    required CreatePostRequest input,
    required List<PostImageRequest> images,
  });
}
