import 'package:flutter/material.dart';

import 'trang_chu/trang_chu.dart';
import 'lich/lich.dart';
import 'kinh_sach/kinh_sach.dart';
import 'tai_khoan/tai_khoan.dart';
import 'qr/qr_scan.dart';

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

  final List<Widget> _pages = const [
    TrangChu(),
    LichPage(),
    KinhSachPage(),
    TaiKhoanPage(),
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openQrScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const QrScanPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ==============================
      // NÚT QR Ở GIỮA
      // ==============================
      floatingActionButton:
          FloatingActionButton.large(
        onPressed: _openQrScanner,

        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,

        elevation: 5,

        shape: const CircleBorder(),

        child: const Icon(
          Icons.qr_code_scanner_rounded,
          size: 35,
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // ==============================
      // MENU DƯỚI
      // ==============================
      bottomNavigationBar: BottomAppBar(
        height: 75,

        color: Colors.white,

        elevation: 10,

        notchMargin: 8,

        shape:
            const CircularNotchedRectangle(),

        child: Row(
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Trang chủ',
            ),

            _buildNavItem(
              index: 1,
              icon:
                  Icons.calendar_month_outlined,
              selectedIcon:
                  Icons.calendar_month,
              label: 'Lịch',
            ),

            // Chừa chỗ cho QR
            const SizedBox(width: 75),

            _buildNavItem(
              index: 2,
              icon:
                  Icons.menu_book_outlined,
              selectedIcon:
                  Icons.menu_book,
              label: 'Kinh sách',
            ),

            _buildNavItem(
              index: 3,
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
    final selected =
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