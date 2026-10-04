import 'dart:typed_data';

import 'package:neu_trade/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/post/domain/entities/create_post_request.dart';

class PostServices {
  PostServices({required this.userId, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  final String userId;
  final SupabaseClient _client;

  void _requireSession() {
    if (_client.auth.currentUser?.id != userId) {
      throw ServerException(message: 'Vui lòng đăng nhập lại.');
    }
  }

  Future<String> getStudentId() async {
    _requireSession();
    final row = await _client
        .from('sinh_vien')
        .select('msv')
        .eq('sinhvien_id', userId)
        .single();
    final studentId = row['msv'] as String?;
    if (studentId == null || !RegExp(r'^[A-Za-z0-9]+$').hasMatch(studentId)) {
      throw ServerException(
        message:
            'Vui lòng hoàn thiện mã sinh viên trong hồ sơ trước khi đăng bài.',
      );
    }
    return studentId;
  }

  Future<Map<String, dynamic>> getOptions() async {
    _requireSession();
    final result = await _client.rpc('get_post_options');
    return Map<String, dynamic>.from(result as Map);
  }

  Future<UploadedPostImage> uploadImage({
    required String requestId,
    required int index,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
    _requireSession();

    final studentId = await getStudentId();
    final path = '$studentId/$requestId/$index.$extension';

    await _client.storage
        .from('documents')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    final url = _client.storage.from('documents').getPublicUrl(path);
    return UploadedPostImage(path: path, url: url);
  }

  Future<void> removeImage(String path) async {
    _requireSession();
    await _client.storage.from('documents').remove([path]);
  }

  Future<Map<String, dynamic>?> getSubmittedPost(String requestId) async {
    _requireSession();
    final result = await _client.rpc(
      'get_post_result',
      params: {'p_request_id': requestId},
    );
    return result == null ? null : Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> createPost(Map<String, dynamic> params) async {
    _requireSession();
    final result = await _client.rpc('create_post', params: params);
    return Map<String, dynamic>.from(result as Map);
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    _requireSession();
    final result = await _client
        .from('tin_dang')
        .select('*,tai_lieu!inner(*)')
        .eq('trang_thai_tin', 'DangHienThi')
        .order('ngay_tao', ascending: false)
        .limit(50);
    return result;
  }

  Future<Map<String, dynamic>> getPost({required int postId}) async {
    _requireSession();
    final result = await _client
        .from('tin_dang')
        .select('*,tai_lieu!inner(*)')
        .eq('tindang_id', postId)
        .eq('trang_thai_tin', 'DangHienThi')
        .order('ngay_tao', ascending: false)
        .single();
    return result;
  }
}
