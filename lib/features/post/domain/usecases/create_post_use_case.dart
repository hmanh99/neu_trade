import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';

import '../entities/create_post_request.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostParams {
  const CreatePostParams({
    required this.requestId,
    required this.input,
    required this.images,
  });

  final String requestId;
  final CreatePostRequest input;
  final List<PostImageRequest> images;
}

class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  const CreatePostUseCase(this.repository);

  final PostRepository repository;

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) async {
    if (params.images.isEmpty) {
      return Left(Failure('Vui lòng chọn ít nhất một ảnh.'));
    }
    if (params.images.length > maxPostImages) {
      return Left(Failure('Chỉ được chọn tối đa $maxPostImages ảnh.'));
    }
    return repository.createPost(
      requestId: params.requestId,
      input: params.input,
      images: params.images,
    );
  }
}
