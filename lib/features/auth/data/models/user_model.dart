import 'package:neu_trade/features/auth/domain/entities/user_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromJson(User user, {String? username}) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
    );
  }

  UserEntity toEntity() {
    return UserEntity(id: id, email: email);
  }

  factory UserModel.empty() => const UserModel(id: '', email: '');
}
