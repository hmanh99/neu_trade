import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/post_history_entity.dart';
import '../../domain/entities/post_history_image_input.dart';
import '../../domain/entities/post_history_update_request.dart';
import '../../domain/repositories/post_history_repository.dart';
import '../datasources/post_history_remote_datasource.dart';
import '../models/post_history_uploaded_image_model.dart';

class PostHistoryRepositoryImpl implements PostHistoryRepository {
  PostHistoryRepositoryImpl({
    required this.remoteDatasource,
    required this.uuid,
  });

  final PostHistoryRemoteDatasource remoteDatasource;
  final Uuid uuid;

  @override
  Future<Either<Failure, List<PostHistoryEntity>>> getMyPosts() async {
    try {
      final models = await remoteDatasource.getMyPosts();
      return Right(
        models.map((model) => model.toEntity()).toList(growable: false),
      );
    } on ServerException catch (error) {
      return Left(Failure(error.message));
    } catch (_) {
      return Left(
        Failure('Không thể tải lịch sử bài đăng. Vui lòng thử lại.'),
      );
    }
  }

  @override
  Future<Either<Failure, PostHistoryEntity>> getMyPost({
    required int postId,
  }) async {
    try {
      final model = await remoteDatasource.getMyPost(postId: postId);
      return Right(model.toEntity());
    } on ServerException catch (error) {
      return Left(Failure(error.message));
    } catch (_) {
      return Left(
        Failure('Không thể tải chi tiết bài đăng. Vui lòng thử lại.'),
      );
    }
  }

  @override
  Future<Either<Failure, PostHistoryEntity>> updateMyPost({
    required int postId,
    required PostHistoryUpdateRequest input,
    required List<PostHistoryImageInput> images,
  }) async {
    final editRequestId = uuid.v4();
    final newlyUploadedPaths = <String>[];
    final orderedPayloads = <PostHistoryImagePayloadModel>[];
    var newImageIndex = 0;

    try {
      for (final item in images) {
        switch (item) {
          case ExistingPostHistoryImage(:final url):
            orderedPayloads.add(PostHistoryImagePayloadModel(url: url));
          case NewPostHistoryImage():
            final uploaded = await remoteDatasource.uploadImage(
              requestId: editRequestId,
              index: newImageIndex,
              image: item,
            );
            newImageIndex++;
            if (uploaded.path != null) {
              newlyUploadedPaths.add(uploaded.path!);
            }
            orderedPayloads.add(uploaded);
        }
      }

      final result = await remoteDatasource.updateMyPost(
        postId: postId,
        input: input,
        images: orderedPayloads,
      );

      // Clean up old images that are no longer referenced by the updated post.
      await _removePathsBestEffort(result.removedImagePaths);

      return Right(result.post.toEntity());
    } on ServerException catch (error) {
      await _removePathsBestEffort(newlyUploadedPaths);
      return Left(Failure(error.message));
    } catch (_) {
      await _removePathsBestEffort(newlyUploadedPaths);
      return Left(
        Failure('Không thể cập nhật bài đăng. Vui lòng thử lại.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMyPost({required int postId}) async {
    try {
      final imagePaths = await remoteDatasource.deleteMyPost(postId: postId);
      await _removePathsBestEffort(imagePaths);
      return const Right(unit);
    } on ServerException catch (error) {
      return Left(Failure(error.message));
    } catch (_) {
      return Left(Failure('Không thể xoá bài đăng. Vui lòng thử lại.'));
    }
  }

  Future<void> _removePathsBestEffort(List<String> paths) async {
    for (final path in paths) {
      try {
        await remoteDatasource.removeImage(path);
      } catch (_) {
        // Ignore best-effort storage cleanup errors.
      }
    }
  }
}
