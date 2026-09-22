import 'package:flutter/material.dart';

import 'trang_chu/trang_chu.dart';
import 'lich/lich.dart';
import 'tu_tap/trang_tu_tap.dart';
import 'kinh_sach/kinh_sach.dart';
import 'tai_khoan/tai_khoan.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const Color primaryBrown = Color(0xFFA56A12);
  static const Color lightBrown = Color(0xFFFFE8BC);

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TrangChu(
            onOpenCalendar: () => _changeTab(1),
            onOpenPractice: () => _changeTab(2),
            onOpenScripture: () => _changeTab(3),
            onOpenProfile: () => _changeTab(4),
          ),

          const LichPage(),
          const TrangTuTap(),
          const KinhSachPage(),
          const TaiKhoanPage(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: lightBrown,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home,
              color: primaryBrown,
            ),
            label: 'Trang chủ',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(
              Icons.calendar_month,
              color: primaryBrown,
            ),
            label: 'Lịch',
          ),

          NavigationDestination(
            icon: Icon(Icons.self_improvement),
            selectedIcon: Icon(
              Icons.self_improvement,
              color: primaryBrown,
            ),
            label: 'Tu tập',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(
              Icons.menu_book,
              color: primaryBrown,
            ),
            label: 'Kinh sách',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: primaryBrown,
            ),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}