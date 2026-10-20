import 'package:neu_trade/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionServices {
  TransactionServices({required this.userId, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final String userId;
  final SupabaseClient _client;

  void _requireSession() {
    if (_client.auth.currentUser?.id != userId) {
      throw ServerException(message: 'Vui lòng đăng nhập lại.');
    }
  }

  /// Create a new transaction (reserve a post).
  Future<Map<String, dynamic>> createTransaction({
    required int postId,
    String? note,
  }) async {
    _requireSession();
    final result = await _client.rpc(
      'create_transaction',
      params: {'p_tindang_id': postId, 'p_note': note},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  /// Get all transactions for the current user (as buyer or seller).
  Future<List<Map<String, dynamic>>> getTransactions() async {
    _requireSession();
    final result = await _client.rpc('get_my_transactions');
    if (result == null) return [];
    final list = result as List;
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  /// Get a single transaction by ID.
  Future<Map<String, dynamic>> getTransaction({
    required int transactionId,
  }) async {
    _requireSession();
    try {
      final result = await _client.rpc(
        'get_transaction_detail',
        params: {'p_giaodich_id': transactionId},
      );
      return Map<String, dynamic>.from(result as Map);
    } catch (_) {
      // Fallback to table query joined with tin_dang
      final result = await _client
          .from('giao_dich')
          .select(
            '*, tin_dang!inner(tieu_de, nguoi_dang_id, ho_ten_nguoi_dang, hinh_anh)',
          )
          .eq('giaodich_id', transactionId)
          .single();
      return result;
    }
  }

  /// Complete a transaction (seller marks as done).
  Future<Map<String, dynamic>> completeTransaction({
    required int transactionId,
  }) async {
    _requireSession();
    final result = await _client.rpc(
      'complete_transaction',
      params: {'p_giaodich_id': transactionId},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  /// Cancel a transaction (buyer or seller can cancel while in DangGiuCho).
  Future<Map<String, dynamic>> cancelTransaction({
    required int transactionId,
    String? reason,
  }) async {
    _requireSession();
    final result = await _client.rpc(
      'cancel_transaction',
      params: {
        'p_giaodich_id': transactionId,
        'p_ly_do': reason,
      },
    );
    return Map<String, dynamic>.from(result as Map);
  }
}

