import 'package:neu_trade/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsServices {
  StatisticsServices({required this.userId, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final String userId;
  final SupabaseClient _client;

  void _requireSession() {
    if (_client.auth.currentUser?.id != userId) {
      throw ServerException(message: 'Vui lòng đăng nhập lại.');
    }
  }

  Future<List<Map<String, dynamic>>> getCirculationStats() async {
    _requireSession();
    final result = await _client.rpc('get_thong_ke_luan_chuyen');
    final list = result as List<dynamic>? ?? const [];
    return list
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
