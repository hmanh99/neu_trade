import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../entities/post_history_entity.dart';
import '../entities/post_history_image_input.dart';
import '../entities/post_history_update_request.dart';
import '../repositories/post_history_repository.dart';

class UpdatePostHistoryParams extends Equatable {
  const UpdatePostHistoryParams({
    required this.postId,
    required this.input,
    required this.images,
  });

  final int postId;
  final PostHistoryUpdateRequest input;
  final List<PostHistoryImageInput> images;

  @override
  List<Object?> get props => [postId, input, images];
}

class UpdatePostHistoryUsecase
    implements UseCase<PostHistoryEntity, UpdatePostHistoryParams> {
  const UpdatePostHistoryUsecase(this.repository);

  final PostHistoryRepository repository;

  @override
  Future<Either<Failure, PostHistoryEntity>> call(
    UpdatePostHistoryParams params,
  ) {
    return repository.updateMyPost(
      postId: params.postId,
      input: params.input,
      images: params.images,
    );
  }
}
