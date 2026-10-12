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
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
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
              backgroundColor: Colors.red,
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
            backgroundColor: const Color(0xFFF5F7FB),
            appBar: AppBar(
              title: const Text('Hồ sơ'),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.white,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ProfileField(
                    icon: Icons.badge_outlined,
                    label: 'Mã sinh viên',
                    value: profile.studentId,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ProfileField(
                    icon: Icons.person_outline,
                    label: 'Họ và tên',
                    value: profile.fullName,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ProfileField(
                    icon: Icons.phone_outlined,
                    label: 'Số điện thoại',
                    value: profile.phone,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ProfileField(
                    icon: Icons.alternate_email,
                    label: 'Email sinh viên',
                    value: profile.email,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _confirmSignOut,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: ColorConstants.buttonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Đăng xuất",
                    style: TextStyle(color: ColorConstants.buttonTextColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
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
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Text(
              _initials,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final stats = [
                Stat(
                  value:
                      profile.reputationScore?.toStringAsFixed(2) ??
                      'Chưa có dữ liệu',
                  label: 'Điểm uy tín',
                ),
                Stat(
                  value:
                      profile.cancelledOrderCount?.toString() ??
                      'Chưa có dữ liệu',
                  label: 'Số lần hủy đơn',
                ),
              ];
              if (constraints.maxWidth < 260 ||
                  MediaQuery.textScalerOf(context).scale(14) > 20) {
                return Column(
                  children: [stats[0], const SizedBox(height: 20), stats[1]],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: stats[0]),
                  const SizedBox(width: 12),
                  Expanded(child: stats[1]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

