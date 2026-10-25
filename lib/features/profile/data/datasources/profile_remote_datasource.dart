import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/services/profile_services.dart';
import 'package:neu_trade/features/profile/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfileModel?> getProfile({required String userId});

  Future<void> saveProfile({required UserProfileModel profile});

  Future<void> signOut();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDatasource {
  ProfileRemoteDataSourceImpl(this._profileService);

  final ProfileServices _profileService;

  @override
  Future<UserProfileModel?> getProfile({required String userId}) async {
    try {
      final data = await _profileService.getProfile(userId: userId);
      return data == null ? null : UserProfileModel.fromJson(data);
    } catch (_) {
      throw ServerException(
        message: 'Không thể tải thông tin. Vui lòng thử lại.',
      );
    }
  }

  @override
  Future<void> saveProfile({required UserProfileModel profile}) async {
    try {
      await _profileService.saveProfile(profile: profile.toJson());
    } on PostgrestException catch (error) {
      throw ServerException(
        message: error.code == '23505'
            ? 'Mã sinh viên hoặc email đã được sử dụng.'
            : 'Không thể lưu thông tin. Vui lòng thử lại.',
      );
    } catch (_) {
      throw ServerException(
        message: 'Không thể lưu thông tin. Vui lòng thử lại.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _profileService.signOut();
    } on AuthApiException catch (error) {
      throw ServerException(message: error.message);
    } catch (_) {
      throw ServerException(
        message: 'Không thể đăng xuất. Vui lòng thử lại.',
      );
    }
  }
}
