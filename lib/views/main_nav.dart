import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import 'kinh_sach/kinh_sach.dart';
import 'lich/lich_page.dart';
import 'tai_khoan/tai_khoan.dart';
import 'temples/temple_list_page.dart';
import 'trang_chu/trang_chu.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    TrangChu(onNavigate: _changeTab),
    const TempleListPage(),
    const KinhSachPage(),
    LichPage(onNavigate: _changeTab),
    const TaiKhoanPage(),
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changeTab,
      ),
    );
  }
}

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      height: 72,
      backgroundColor: Colors.white,
      indicatorColor: AppTheme.surface,
      animationDuration: const Duration(milliseconds: 220),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon: Icon(Icons.temple_buddhist_outlined),
          selectedIcon: Icon(Icons.temple_buddhist),
          label: 'Chùa',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Kinh sách',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Lịch',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}
