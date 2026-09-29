import 'dart:typed_data';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostServices {
  PostServices({required this.userId, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  final String userId;
  final SupabaseClient _client;

  void _requireSession() {
    if (_client.auth.currentUser?.id != userId) {
      throw ServerException(
        message: 'Phiên đăng nhập đã thay đổi. Vui lòng đăng nhập lại.',
      );
    }
  }

  Future<Map<String, dynamic>> getOptions() async {
    _requireSession();
    return Map<String, dynamic>.from(
      await _client.rpc('get_post_options') as Map,
    );
  }

  Future<String> getStudentId() async {
    _requireSession();
    final row = await _client
        .from('sinh_vien')
        .select('msv')
        .eq('sinhvien_id', userId)
        .maybeSingle();
    final studentId = row?['msv'] as String?;
    if (studentId == null || !RegExp(r'^[A-Za-z0-9]+$').hasMatch(studentId)) {
      throw ServerException(
        message:
            'Vui lòng hoàn thiện mã sinh viên trong hồ sơ trước khi đăng bài.',
      );
    }
    return studentId;
  }

  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    _requireSession();
    await _client.storage
        .from('documents')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    return _client.storage.from('documents').getPublicUrl(path);
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
    return Map<String, dynamic>.from(
      await _client.rpc('create_post', params: params) as Map,
    );
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
}
