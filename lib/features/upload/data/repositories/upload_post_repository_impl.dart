import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/error/failure.dart';
import '../../domain/entities/create_upload_post_request.dart';
import '../../domain/entities/upload_post_entity.dart';
import '../../domain/repositories/upload_post_repository.dart';
import '../datasources/post_remote_datasources.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required this.remoteDatasource});

  final PostRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, UploadPostEntity>> createPost({
    required String requestId,
    required CreatePostRequest input,
    required List<PostImageRequest> images,
  }) async {
    final uploaded = <UploadedPostImage>[];
    var preflightComplete = false;
    var submissionStarted = false;

    try {
      final existing = await remoteDatasource.getSubmittedPost(requestId);
      if (existing != null) return Right(existing.toEntity());
      preflightComplete = true;

      for (var index = 0; index < images.length; index++) {
        uploaded.add(
          await remoteDatasource.uploadImage(
            requestId: requestId,
            index: index,
            image: images[index],
          ),
        );
      }

      submissionStarted = true;
      final post = await remoteDatasource.createPost(
        requestId: requestId,
        input: input,
        images: uploaded,
      );
      return Right(post.toEntity());
    } on ServerException catch (error) {
      await _removeUploadedImages(uploaded);
      return Left(Failure(error.message));
    } catch (_) {
      if (!preflightComplete) {
        return Left(
          Failure('Chưa thể kiểm tra kết quả đăng bài. Vui lòng thử lại.'),
        );
      }
      if (submissionStarted) {
        try {
          final saved = await remoteDatasource.getSubmittedPost(requestId);
          if (saved != null) return Right(saved.toEntity());
          await _removeUploadedImages(uploaded);
        } catch (_) {
          return Left(
            Failure('Chưa xác định được kết quả đăng bài. Vui lòng thử lại.'),
          );
        }
      } else {
        await _removeUploadedImages(uploaded);
      }
      return Left(Failure('Không thể đăng bài. Vui lòng thử lại.'));
    }
  }

  Future<void> _removeUploadedImages(List<UploadedPostImage> images) async {
    for (final image in images) {
      try {
        await remoteDatasource.removeImage(image.path);
      } catch (_) {
        // The Storage policy also prevents deleting an image referenced by a post.
      }
    }
  }
}
