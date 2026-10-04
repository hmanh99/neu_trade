import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/services/post_services.dart';
import 'package:neu_trade/features/post/domain/entities/create_post_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_model.dart';

abstract class PostRemoteDatasource {
  Future<UploadedPostImage> uploadImage({
    required String requestId,
    required int index,
    required PostImageRequest image,
  });

  Future<void> removeImage(String path);

  Future<PostModel?> getSubmittedPost(String requestId);

  Future<PostModel> createPost({
    required String requestId,
    required CreatePostRequest input,
    required List<UploadedPostImage> images,
  });

  Future<List<PostModel>> getPosts();

  Future<PostModel> getPost({required int postId});
}

class PostRemoteDataSourceImpl implements PostRemoteDatasource {
  PostRemoteDataSourceImpl(this._service);

  final PostServices _service;

  @override
  Future<UploadedPostImage> uploadImage({
    required String requestId,
    required int index,
    required PostImageRequest image,
  }) async {
    try {
      return await _service.uploadImage(
        requestId: requestId,
        index: index,
        bytes: image.bytes,
        extension: image.extension,
        contentType: image.contentType,
      );
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<void> removeImage(String path) async {
    try {
      await _service.removeImage(path);
    } on StorageException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<PostModel?> getSubmittedPost(String requestId) async {
    try {
      final json = await _service.getSubmittedPost(requestId);
      return json == null ? null : PostModel.fromJson(json);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<PostModel> createPost({
    required String requestId,
    required CreatePostRequest input,
    required List<UploadedPostImage> images,
  }) async {
    try {
      final json = await _service.createPost({
        'p_request_id': requestId,
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
        'p_images': images.map((image) => image.toJson()).toList(),
      });
      return PostModel.fromJson(json);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final rows = await _service.getPosts();
      return rows.map(PostModel.fromJson).toList(growable: false);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<PostModel> getPost({required int postId}) async {
    try {
      return PostModel.fromJson(await _service.getPost(postId: postId));
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
