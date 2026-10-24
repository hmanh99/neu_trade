import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_names.dart';

class AdminMenuSection extends StatelessWidget {
  const AdminMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Quản trị hệ thống',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
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
              _buildMenuItem(
                context: context,
                icon: Icons.fact_check_outlined,
                iconBg: ColorConstants.blueShade50,
                iconColor: ColorConstants.primaryColor,
                title: 'Duyệt bài đăng',
                subtitle: 'Xét duyệt các tin đăng mới từ sinh viên',
                onTap: () => context.pushNamed(AppRouteNames.adminPosts),
              ),
              const Divider(height: 1, color: ColorConstants.dividerColor),
              _buildMenuItem(
                context: context,
                icon: Icons.gavel_outlined,
                iconBg: ColorConstants.orangeShade50,
                iconColor: const Color(0xFFD97706),
                title: 'Xử lý báo cáo vi phạm',
                subtitle: 'Xem xét và giải quyết các phản ánh vi phạm',
                onTap: () => context.pushNamed(AppRouteNames.adminReports),
              ),
              const Divider(height: 1, color: ColorConstants.dividerColor),
              _buildMenuItem(
                context: context,
                icon: Icons.insights_outlined,
                iconBg: ColorConstants.greenShade50,
                iconColor: const Color(0xFF16A34A),
                title: 'Thống kê luân chuyển',
                subtitle: 'Số liệu sách bàn giao và trao tặng theo học kỳ',
                onTap: () => context.pushNamed(AppRouteNames.circulationStats),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
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
    );
  }
}
