import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';

import '../entities/post_history_entity.dart';
import '../entities/post_history_image_input.dart';
import '../entities/post_history_update_request.dart';

abstract interface class PostHistoryRepository {
  Future<Either<Failure, List<PostHistoryEntity>>> getMyPosts();

  Future<Either<Failure, PostHistoryEntity>> getMyPost({required int postId});

  Future<Either<Failure, PostHistoryEntity>> updateMyPost({
    required int postId,
    required PostHistoryUpdateRequest input,
    required List<PostHistoryImageInput> images,
  });

  Future<Either<Failure, Unit>> deleteMyPost({required int postId});
}
