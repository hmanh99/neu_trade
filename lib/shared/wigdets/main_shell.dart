import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.post_add),
            selectedIcon: Icon(Icons.post_add_outlined),
            label: 'Đăng bài',
          ),
          NavigationDestination(
            icon: Icon(Icons.change_circle_outlined),
            selectedIcon: Icon(Icons.change_circle),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        onDestinationSelected: navigationShell.goBranch,
      ),
    );
  }
}
