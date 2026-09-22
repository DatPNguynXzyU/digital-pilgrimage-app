import 'package:flutter/material.dart';

class TrangChu extends StatefulWidget {
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenPractice;
  final VoidCallback onOpenScripture;
  final VoidCallback onOpenProfile;

  const TrangChu({
    super.key,
    required this.onOpenCalendar,
    required this.onOpenPractice,
    required this.onOpenScripture,
    required this.onOpenProfile,
  });

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  static const Color primaryBrown = Color(0xFFA56A12);
  static const Color lightBrown = Color(0xFFFFE8BC);

  DateTime selectedDate = DateTime.now();

  final List<String> thu = [
    'Hai',
    'Ba',
    'Tư',
    'Năm',
    'Sáu',
    'Bảy',
    'CN',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildWeekCalendar(),

              const SizedBox(height: 25),

              _buildCalendarCard(),

              const SizedBox(height: 25),

              _buildQuote(),

              const SizedBox(height: 30),

              _buildPractice(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: primaryBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.temple_buddhist,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          const Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Xin chào, ',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Phật tử!',
                    style: TextStyle(
                      color: primaryBrown,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              size: 31,
            ),
            onPressed: _showNotifications,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // THÔNG BÁO
  // =====================================================

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: lightBrown,
                  child: Icon(
                    Icons.event,
                    color: primaryBrown,
                  ),
                ),
                title: const Text('Nhắc nhở tu tập'),
                subtitle: const Text(
                  'Đã đến giờ tu tập hôm nay.',
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onOpenPractice();
                },
              ),

              const Divider(),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: lightBrown,
                  child: Icon(
                    Icons.menu_book,
                    color: primaryBrown,
                  ),
                ),
                title: const Text('Kinh sách'),
                subtitle: const Text(
                  'Khám phá nội dung kinh sách hôm nay.',
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onOpenScripture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // LỊCH TUẦN
  // =====================================================

  Widget _buildWeekCalendar() {
    final today = DateTime.now();

    // Thứ Hai của tuần hiện tại
    final monday = today.subtract(
      Duration(days: today.weekday - 1),
    );

    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = monday.add(Duration(days: index));

          final selected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final sunday = date.weekday == DateTime.sunday;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Container(
              width: 62,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  Text(
                    thu[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: sunday
                          ? Colors.red
                          : Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 77,
                    decoration: BoxDecoration(
                      color: selected
                          ? primaryBrown
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : sunday
                                    ? Colors.red
                                    : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${date.month}',
                          style: TextStyle(
                            color: selected
                                ? Colors.white70
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // CARD NGÀY
  // =====================================================

  Widget _buildCalendarCard() {
    String weekdayName;

    switch (selectedDate.weekday) {
      case DateTime.monday:
        weekdayName = 'Thứ Hai';
        break;
      case DateTime.tuesday:
        weekdayName = 'Thứ Ba';
        break;
      case DateTime.wednesday:
        weekdayName = 'Thứ Tư';
        break;
      case DateTime.thursday:
        weekdayName = 'Thứ Năm';
        break;
      case DateTime.friday:
        weekdayName = 'Thứ Sáu';
        break;
      case DateTime.saturday:
        weekdayName = 'Thứ Bảy';
        break;
      default:
        weekdayName = 'Chủ Nhật';
    }

    return GestureDetector(
      onTap: widget.onOpenCalendar,

      child: Container(
        height: 360,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/phat_home.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFF4D6164),
                  child: const Icon(
                    Icons.temple_buddhist,
                    size: 180,
                    color: Colors.white24,
                  ),
                );
              },
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$weekdayName · '
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 13),

                  const Row(
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Âm lịch',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /*
                    Tạm thời hiển thị ngày đang chọn.

                    Bước sau chúng ta sẽ thêm thư viện âm lịch
                    để chuyển chính xác Dương lịch -> Âm lịch.
                  */
                  Text(
                    '${selectedDate.day}',
                    style: const TextStyle(
                      fontSize: 70,
                      height: 1,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Tháng ${selectedDate.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Xem lịch chi tiết →',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PHÁP CÚ
  // =====================================================

  Widget _buildQuote() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFAF2),
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 30,
      ),
      child: const Column(
        children: [
          Text(
            '"Tinh cần giữa phóng dật,\n'
            'Tỉnh thức giữa quần mê.\n'
            'Người trí như ngựa phi,\n'
            'Bỏ sau con ngựa hèn."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),

          SizedBox(height: 22),

          Text(
            'Trích Kinh Pháp Cú (Phẩm Phóng Dật)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TU TẬP
  // =====================================================

  Widget _buildPractice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tu tập nổi bật',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              _practiceCard(
                icon: Icons.self_improvement,
                title: 'Thiền',
              ),
              _practiceCard(
                icon: Icons.menu_book,
                title: 'Tụng kinh',
              ),
              _practiceCard(
                icon: Icons.spa,
                title: 'Niệm Phật',
              ),
              _practiceCard(
                icon: Icons.favorite_outline,
                title: 'Chú Đại Bi',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _practiceCard({
    required IconData icon,
    required String title,
  }) {
    return GestureDetector(
      onTap: widget.onOpenPractice,

      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: lightBrown,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primaryBrown,
                size: 28,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}