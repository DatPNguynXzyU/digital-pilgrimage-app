import 'package:flutter/material.dart';

import 'trang_chu/trang_chu.dart';
import 'kinh_sach/kinh_sach.dart';
import 'tai_khoan/tai_khoan.dart';
import 'lich/lich_page.dart';
import 'temples/temple_list_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int _currentIndex = 0;

  static const Color primaryBrown =
      Color(0xFFA56A12);

  // ==============================
  // CÁC TRANG
  // ==============================
  final List<Widget> _pages = const [
    TrangChu(),          // 0
    LichPage(),          // 1
    TempleListPage(),    // 2
    KinhSachPage(),      // 3
    TaiKhoanPage(),      // 4
  ];

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
        children: _pages,
      ),

      // ==============================
      // MENU DƯỚI
      // ==============================
      bottomNavigationBar: BottomAppBar(
        height: 75,
        color: Colors.white,
        elevation: 10,

        child: Row(
          children: [
            // Trang chủ
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Trang chủ',
            ),

            // Lịch
            _buildNavItem(
              index: 1,
              icon:
                  Icons.calendar_month_outlined,
              selectedIcon:
                  Icons.calendar_month,
              label: 'Lịch',
            ),

            // Chùa
            _buildNavItem(
              index: 2,
              icon:
                  Icons.temple_buddhist_outlined,
              selectedIcon:
                  Icons.temple_buddhist,
              label: 'Chùa',
            ),

            // Kinh sách
            _buildNavItem(
              index: 3,
              icon:
                  Icons.menu_book_outlined,
              selectedIcon:
                  Icons.menu_book,
              label: 'Kinh sách',
            ),

            // Cá nhân
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected =
        _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _changeTab(index),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              selected
                  ? selectedIcon
                  : icon,

              size: 26,

              color: selected
                  ? primaryBrown
                  : Colors.grey,
            ),

            const SizedBox(height: 4),

            Text(
              label,

              maxLines: 1,

              style: TextStyle(
                fontSize: 11,

                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,

                color: selected
                    ? primaryBrown
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}