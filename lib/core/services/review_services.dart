import 'package:neu_trade/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewServices {
  ReviewServices({required this.userId, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final String userId;
  final SupabaseClient _client;

  void _requireSession() {
    if (_client.auth.currentUser?.id != userId) {
      throw ServerException(message: 'Vui lòng đăng nhập lại.');
    }
  }

  Future<Map<String, dynamic>> createReview({
    required int transactionId,
    required int stars,
    String? content,
  }) async {
    _requireSession();
    final result = await _client.rpc(
      'create_review',
      params: {
        'p_giaodich_id': transactionId,
        'p_so_sao': stars,
        'p_noi_dung': content,
      },
    );
    return Map<String, dynamic>.from(result as Map);
  }
}
