import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_event.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_state.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_event.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_state.dart';
import 'package:neu_trade/features/profile/presentation/widgets/profile_field.dart';

import '../widgets/profile_message.dart';
import '../widgets/stat.dart';
import 'package:neu_trade/core/services/profile_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadEvent());
  }

  Future<void> _reload() async {
    final bloc = context.read<ProfileBloc>();
    if (bloc.state is ProfileLoadingState || bloc.state is ProfileSavingState) {
      return;
    }
    final completed = bloc.stream.firstWhere(
      (state) => state is ProfileLoadedState || state is ProfileErrorState,
      orElse: () => const ProfileInitialState(),
    );
    bloc.add(const ProfileLoadEvent());
    await completed;
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Xác nhận đăng xuất',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ColorConstants.errorColor,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(const AuthSignOutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.message),
              backgroundColor: ColorConstants.snackBarFailedColor,
            ),
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final loading =
              state is ProfileInitialState ||
              state is ProfileLoadingState ||
              state is ProfileSavingState;
          return Scaffold(
            backgroundColor: ColorConstants.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Hồ sơ sinh viên',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.textPrimaryColor,
                  letterSpacing: -0.4,
                ),
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  tooltip: 'Tải lại hồ sơ',
                  onPressed: loading ? null : _reload,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: SafeArea(child: _body(state)),
          );
        },
      ),
    );
  }

  Widget _body(ProfileState state) {
    if (state is ProfileErrorState) {
      return ProfileMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Không thể tải hồ sơ',
        message: 'Vui lòng kiểm tra kết nối và thử lại.',
        onRetry: _reload,
      );
    }
    if (state is ProfileLoadedState) {
      final profile = state.profile;
      if (profile == null) {
        return ProfileMessage(
          icon: Icons.person_outline,
          title: 'Chưa có thông tin sinh viên',
          message: 'Tài khoản của bạn chưa có hồ sơ được lưu.',
          onRetry: _reload,
        );
      }
      return RefreshIndicator(
        color: ColorConstants.primaryColor,
        onRefresh: _reload,
        child: ListView(
          key: const PageStorageKey('profile-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _ProfileHeader(profile: profile),
            const SizedBox(height: 24),
            const Text(
              'Thông tin sinh viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColorConstants.borderLightColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x060F172A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfileField(
                    icon: Icons.badge_outlined,
                    label: 'Mã sinh viên',
                    value: profile.studentId,
                  ),
                  const Divider(color: ColorConstants.dividerColor),
                  ProfileField(
                    icon: Icons.person_outline,
                    label: 'Họ và tên',
                    value: profile.fullName,
                  ),
                  const Divider(color: ColorConstants.dividerColor),
                  ProfileField(
                    icon: Icons.phone_outlined,
                    label: 'Số điện thoại',
                    value: profile.phone,
                  ),
                  const Divider(color: ColorConstants.dividerColor),
                  ProfileField(
                    icon: Icons.alternate_email,
                    label: 'Email sinh viên',
                    value: profile.email,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _confirmSignOut,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: ColorConstants.redShade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ColorConstants.redShade100),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: ColorConstants.errorColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Đăng xuất",
                      style: TextStyle(
                        color: ColorConstants.errorColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(color: ColorConstants.primaryColor),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  String get _initials {
    final words = profile.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words.length == 1
        ? words.first.characters.first.toUpperCase()
        : (words.first.characters.first + words.last.characters.first)
              .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ColorConstants.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.primaryColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: ColorConstants.primaryColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: ColorConstants.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'MSV: ${profile.studentId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: ProfileServices()
                  .getUserPublicStats(userId: profile.userId)
                  .catchError((_) => null),
              builder: (context, snapshot) {
                final rating =
                    snapshot.data?['diem_trung_binh']?.toString() ?? '5.0';
                final count =
                    snapshot.data?['tong_danh_gia']?.toString() ?? '0';
                final cancelCount =
                    snapshot.data?['so_lan_huy_don']?.toString() ??
                        profile.cancelledOrderCount?.toString() ??
                        '0';
                final stats = [
                  Stat(value: '$rating★ ($count)', label: 'Đánh giá'),
                  Stat(
                    value: cancelCount,
                    label: 'Hủy đơn',
                  ),
                ];
                return Row(
                  children: [
                    Expanded(child: stats[0]),
                    Container(
                      height: 36,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(child: stats[1]),
                  ],
                );
              },
            ),

          ),
        ],
      ),
    );
  }
}
