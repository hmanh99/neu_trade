import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';

import '../entities/create_upload_post_request.dart';
import '../entities/upload_post_entity.dart';

abstract interface class PostRepository {
  Future<Either<Failure, UploadPostEntity>> createPost({
    required String requestId,
    required CreatePostRequest input,
    required List<PostImageRequest> images,
  });
}
