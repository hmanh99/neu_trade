import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A0F172A),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(
            top: BorderSide(color: ColorConstants.borderLightColor, width: 1),
          ),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: bottomPadding > 0 ? bottomPadding : 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              selectedIndex: currentIndex,
              label: 'Trang chủ',
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              onTap: () => _onTabSelected(0),
            ),
            _buildNavItem(
              index: 1,
              selectedIndex: currentIndex,
              label: 'Đăng bài',
              icon: Icons.add_circle_outline_rounded,
              activeIcon: Icons.add_circle_outline_rounded,
              onTap: () => _onTabSelected(1),
            ),
            _buildNavItem(
              index: 2,
              selectedIndex: currentIndex,
              label: 'Giao dịch',
              icon: Icons.swap_horiz_rounded,
              activeIcon: Icons.swap_horizontal_circle_rounded,
              onTap: () => _onTabSelected(2),
            ),
            _buildNavItem(
              index: 3,
              selectedIndex: currentIndex,
              label: 'Hồ sơ',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              onTap: () => _onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildNavItem({
    required int index,
    required int selectedIndex,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.greyShade500,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? ColorConstants.primaryColor
                    : ColorConstants.greyShade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
