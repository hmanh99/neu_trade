import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/services/post_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/post_history_image_input.dart';
import '../../domain/entities/post_history_update_request.dart';
import '../models/post_history_model.dart';
import '../models/post_history_uploaded_image_model.dart';

abstract class PostHistoryRemoteDatasource {
  Future<List<PostHistoryModel>> getMyPosts();

  Future<PostHistoryModel> getMyPost({required int postId});

  Future<PostHistoryImagePayloadModel> uploadImage({
    required String requestId,
    required int index,
    required NewPostHistoryImage image,
  });

  Future<void> removeImage(String path);

  Future<({PostHistoryModel post, List<String> removedImagePaths})> updateMyPost({
    required int postId,
    required PostHistoryUpdateRequest input,
    required List<PostHistoryImagePayloadModel> images,
  });

  Future<List<String>> deleteMyPost({required int postId});
}

class PostHistoryRemoteDatasourceImpl implements PostHistoryRemoteDatasource {
  const PostHistoryRemoteDatasourceImpl(this._postServices);

  final PostServices _postServices;

  @override
  Future<List<PostHistoryModel>> getMyPosts() async {
    try {
      final rows = await _postServices.getPostsByUserId();
      return rows
          .map((row) => PostHistoryModel.fromJson(row))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    } on FormatException catch (error) {
      throw ServerException(message: error.message.toString());
    }
  }

  @override
  Future<PostHistoryModel> getMyPost({required int postId}) async {
    try {
      final row = await _postServices.getPost(postId: postId);
      return PostHistoryModel.fromJson(row);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    } on FormatException catch (error) {
      throw ServerException(message: error.message.toString());
    }
  }

  @override
  Future<PostHistoryImagePayloadModel> uploadImage({
    required String requestId,
    required int index,
    required NewPostHistoryImage image,
  }) async {
    try {
      final result = await _postServices.uploadImage(
        requestId: requestId,
        index: index,
        bytes: image.bytes,
        extension: image.extension,
        contentType: image.contentType,
      );
      return PostHistoryImagePayloadModel(path: result.path, url: result.url);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<void> removeImage(String path) async {
    try {
      await _postServices.removeImage(path);
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<({PostHistoryModel post, List<String> removedImagePaths})> updateMyPost({
    required int postId,
    required PostHistoryUpdateRequest input,
    required List<PostHistoryImagePayloadModel> images,
  }) async {
    try {
      final json = await _postServices.updatePost({
        'p_tindang_id': postId,
        'p_document': {
          'danhmuc': input.document.category.toDbString(),
          'ten_sach': input.document.name.trim(),
          'nam_xuat_ban': input.document.publicationYear,
          'do_moi': input.document.condition.toDbString(),
          'ghi_chu_tinh_trang': _optional(input.document.conditionNote),
          'gia_ban': input.document.price.replaceAll(',', '.').trim(),
        },
        'p_post': {
          'tieu_de': input.title.trim(),
          'noi_dung_mo_ta': _optional(input.description),
          'dia_chi': input.address.toDbString(),
        },
        'p_images': images.map((img) => img.toJson()).toList(growable: false),
      });

      final removedRaw = json['removed_image_paths'];
      final removedPaths = removedRaw is List
          ? removedRaw.whereType<String>().toList(growable: false)
          : const <String>[];

      return (
        post: PostHistoryModel.fromJson(json),
        removedImagePaths: removedPaths,
      );
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    } on FormatException catch (error) {
      throw ServerException(message: error.message.toString());
    }
  }

  @override
  Future<List<String>> deleteMyPost({required int postId}) async {
    try {
      final json = await _postServices.deletePost(postId: postId);
      final pathsRaw = json['image_paths'];
      if (pathsRaw is List) {
        return pathsRaw.whereType<String>().toList(growable: false);
      }
      return const [];
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
