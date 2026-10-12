import 'package:neu_trade/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Calls report RPCs for the authenticated user that opened the post.
class ReportServices {
  ReportServices({required this.userId, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final String userId;
  final SupabaseClient _client;

  void _requireSession() {
    if (_client.auth.currentUser?.id != userId) {
      throw ServerException(message: 'Vui lòng đăng nhập lại.');
    }
  }

  Future<Map<String, dynamic>> createPostReport({
    required int postId,
    required String reason,
    String? description,
  }) async {
    _requireSession();
    final result = await _client.rpc(
      'create_post_report',
      params: {
        'p_tindang_id': postId,
        'p_ly_do': reason,
        'p_chi_tiet': description,
      },
    );
    return Map<String, dynamic>.from(result as Map);
  }
}
