import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_names.dart';
import 'package:neu_trade/features/admin/presentation/widgets/admin_menu_section.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_event.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_state.dart';
import 'package:neu_trade/features/profile/presentation/widgets/info_card.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_message.dart';

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
    if (bloc.state is ProfileLoadingState ||
        bloc.state is ProfileSavingState ||
        bloc.state is ProfileSigningOutState) {
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
      context.read<ProfileBloc>().add(const ProfileSignOutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSignOutErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.snackBarFailedColor,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading =
            state is ProfileInitialState ||
            state is ProfileLoadingState ||
            state is ProfileSavingState ||
            state is ProfileSigningOutState;
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
            ProfileHeader(profile: profile),
            if (!profile.isAdmin) ...[
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
              InfoCard(profile: profile),
              const SizedBox(height: 24),
              const Text(
                'Hoạt động của tôi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              _buildPostHistoryMenuItem(),
            ],
            if (profile.isAdmin) ...[
              const SizedBox(height: 24),
              const AdminMenuSection(),
            ],
            const SizedBox(height: 24),
            InkWell(
              onTap: state is ProfileSigningOutState ? null : _confirmSignOut,
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

  Widget _buildPostHistoryMenuItem() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.pushNamed(AppRouteNames.postHistory),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorConstants.blueShade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history_edu_rounded,
                    color: ColorConstants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch sử bài đăng',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Xem lại và theo dõi trạng thái các tài liệu đã đăng',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorConstants.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: ColorConstants.greyShade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
