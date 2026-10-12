import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/services/post_services.dart';
import 'package:neu_trade/features/upload/domain/entities/create_upload_post_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/upload_post_model.dart';

abstract class PostRemoteDatasource {
  Future<UploadedPostImage> uploadImage({
    required String requestId,
    required int index,
    required PostImageRequest image,
  });

  Future<void> removeImage(String path);

  Future<UploadPostModel?> getSubmittedPost(String requestId);

  Future<UploadPostModel> createPost({
    required String requestId,
    required CreatePostRequest input,
    required List<UploadedPostImage> images,
  });
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
      final result = await _service.uploadImage(
        requestId: requestId,
        index: index,
        bytes: image.bytes,
        extension: image.extension,
        contentType: image.contentType,
      );
      return UploadedPostImage(path: result.path, url: result.url);
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
  Future<UploadPostModel?> getSubmittedPost(String requestId) async {
    try {
      final json = await _service.getSubmittedPost(requestId);
      return json == null ? null : UploadPostModel.fromJson(json);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<UploadPostModel> createPost({
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
      return UploadPostModel.fromJson(json);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }

  String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
