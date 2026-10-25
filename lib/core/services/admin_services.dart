import 'package:neu_trade/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminServices {
  AdminServices({required this.userId, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final String userId;
  final SupabaseClient _client;

  void _requireSession() {
    if (_client.auth.currentUser?.id != userId) {
      throw ServerException(message: 'Vui lòng đăng nhập lại.');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingPosts() async {
    _requireSession();
    try {
      final result = await _client.rpc('admin_get_pending_posts');
      final list = result as List<dynamic>? ?? const [];
      return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Không thể tải danh sách bài chờ duyệt.');
    }
  }

  Future<Map<String, dynamic>> approvePost(int postId) async {
    _requireSession();
    try {
      final result = await _client.rpc(
        'admin_approve_post',
        params: {'p_tindang_id': postId},
      );
      return Map<String, dynamic>.from(result as Map);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Không thể duyệt bài đăng.');
    }
  }

  Future<void> rejectPost(int postId) async {
    _requireSession();
    try {
      final result = await _client.rpc(
        'admin_reject_post',
        params: {'p_tindang_id': postId},
      );
      final map = Map<String, dynamic>.from(result as Map);
      final rawPaths = map['image_paths'] as List<dynamic>? ?? const [];
      final imagePaths = rawPaths.whereType<String>().toList();

      if (imagePaths.isNotEmpty) {
        try {
          await _client.storage.from('documents').remove(imagePaths);
        } catch (_) {
          // Best-effort cleanup of files in storage
        }
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Không thể từ chối bài đăng.');
    }
  }

  Future<List<Map<String, dynamic>>> getReports({String? status}) async {
    _requireSession();
    try {
      final result = await _client.rpc(
        'admin_get_reports',
        params: {'p_status': status},
      );
      final list = result as List<dynamic>? ?? const [];
      return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Không thể tải danh sách báo cáo.');
    }
  }

  Future<Map<String, dynamic>> resolveReport({
    required int reportId,
    required String status,
  }) async {
    _requireSession();
    try {
      final result = await _client.rpc(
        'admin_resolve_report',
        params: {'p_baocao_id': reportId, 'p_trang_thai': status},
      );
      return Map<String, dynamic>.from(result as Map);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Không thể xử lý báo cáo.');
    }
  }

  Future<List<Map<String, dynamic>>> getCirculationStats() async {
    _requireSession();
    try {
      final result = await _client.rpc('get_thong_ke_luan_chuyen');
      final list = result as List<dynamic>? ?? const [];
      return list
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Không thể tải số liệu thống kê luân chuyển.');
    }
  }
}
