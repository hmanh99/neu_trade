import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileServices {
  ProfileServices({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _activeClient => _client ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> getProfile({required String userId}) async {
    return await _activeClient
        .from('sinh_vien')
        .select(
          'sinhvien_id,msv,ho_ten,email_neu,so_dien_thoai,diem_uy_tin,so_lan_huy_don,is_completed',
        )
        .eq('sinhvien_id', userId)
        .maybeSingle();
  }

  Future<void> saveProfile({required Map<String, dynamic> profile}) async {
    await _activeClient
        .from('sinh_vien')
        .upsert(profile, onConflict: 'sinhvien_id');
  }

  Future<Map<String, dynamic>?> getUserPublicStats({
    required String userId,
  }) async {
    try {
      final result = await _activeClient.rpc(
        'get_user_public_stats',
        params: {'p_sinhvien_id': userId},
      );
      if (result == null) return null;
      return Map<String, dynamic>.from(result as Map);
    } catch (_) {
      return null;
    }
  }
}
