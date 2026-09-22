import 'package:flutter/material.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  static const Color primaryBrown = Color(0xFFA56A12);
  static const Color lightBrown = Color(0xFFFFE8BC);
  static const Color backgroundLight = Color(0xFFFFFAF2);

  late DateTime selectedDate;

  final List<String> weekNames = [
    'Hai',
    'Ba',
    'Tư',
    'Năm',
    'Sáu',
    'Bảy',
    'CN',
  ];

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildHeader(),

              const SizedBox(height: 25),

              // LỊCH TUẦN
              _buildWeekCalendar(),

              const SizedBox(height: 25),

              // CARD LỊCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _buildCalendarCard(),
              ),

              const SizedBox(height: 25),

              // PHÁP CÚ
              _buildQuoteSection(),

              const SizedBox(height: 30),

              // KHÁM PHÁ CHÙA
              _buildTempleSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        15,
        0,
      ),
      child: Row(
        children: [
          // LOGO
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: primaryBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.temple_buddhist,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 15),

          // XIN CHÀO
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

          // THÔNG BÁO
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 31,
              color: Colors.black87,
            ),
            onPressed: _showNotifications,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THÔNG BÁO
  // ============================================================

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: lightBrown,
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: primaryBrown,
                        ),
                      ),

                      SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Khám phá thông tin chùa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'Sử dụng nút QR ở thanh menu để quét '
                              'mã tại chùa.',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: lightBrown,
                    child: Icon(
                      Icons.menu_book_outlined,
                      color: primaryBrown,
                    ),
                  ),
                  title: Text(
                    'Kinh sách hôm nay',
                  ),
                  subtitle: Text(
                    'Dành một chút thời gian để đọc và chiêm nghiệm.',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LỊCH TUẦN
  // ============================================================

  Widget _buildWeekCalendar() {
    final DateTime today = DateTime.now();

    // Tìm thứ Hai của tuần hiện tại
    final DateTime monday = today.subtract(
      Duration(
        days: today.weekday - DateTime.monday,
      ),
    );

    return SizedBox(
      height: 135,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        itemCount: 7,
        itemBuilder: (context, index) {
          final DateTime date = monday.add(
            Duration(days: index),
          );

          final bool selected = _isSameDay(
            date,
            selectedDate,
          );

          final bool isSunday =
              date.weekday == DateTime.sunday;

          final bool isToday = _isSameDay(
            date,
            today,
          );

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },

            child: Container(
              width: 62,
              margin: const EdgeInsets.symmetric(
                horizontal: 3,
              ),

              child: Column(
                children: [
                  Text(
                    weekNames[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSunday
                          ? Colors.redAccent
                          : Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    width: 58,
                    height: 88,
                    decoration: BoxDecoration(
                      color: selected
                          ? primaryBrown
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : isSunday
                                    ? Colors.redAccent
                                    : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tạm thời hiển thị tháng ở đây.
                        // Sau này có thể thay bằng ngày âm lịch thật.
                        Text(
                          '${date.month}',
                          style: TextStyle(
                            fontSize: 13,
                            color: selected
                                ? Colors.white70
                                : Colors.grey,
                          ),
                        ),

                        if (isToday && !selected) ...[
                          const SizedBox(height: 5),

                          const CircleAvatar(
                            radius: 3,
                            backgroundColor:
                                primaryBrown,
                          ),
                        ],
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

  // ============================================================
  // CARD NGÀY / ÂM LỊCH
  // ============================================================

  Widget _buildCalendarCard() {
    final String weekday =
        _getWeekdayName(selectedDate.weekday);

    final String day =
        selectedDate.day.toString().padLeft(2, '0');

    final String month =
        selectedDate.month.toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      height: 370,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.grey.shade900,
      ),

      child: Stack(
        fit: StackFit.expand,
        children: [
          // ẢNH NỀN
          Image.asset(
            'assets/images/phat_home.jpg',
            fit: BoxFit.cover,

            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4F7D89),
                      Color(0xFF253D42),
                      Color(0xFF7D592E),
                    ],
                  ),
                ),

                child: const Center(
                  child: Icon(
                    Icons.temple_buddhist,
                    size: 180,
                    color: Colors.white24,
                  ),
                ),
              );
            },
          ),

          // LỚP TỐI
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(
                    alpha: 0.68,
                  ),
                  Colors.black.withValues(
                    alpha: 0.10,
                  ),
                ],
              ),
            ),
          ),

          // NỘI DUNG
          Padding(
            padding: const EdgeInsets.fromLTRB(
              25,
              55,
              20,
              20,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$weekday · '
                  '$day/$month/${selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                const Row(
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      color: Colors.amberAccent,
                      size: 24,
                    ),

                    SizedBox(width: 8),

                    Text(
                      'Âm lịch',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /*
                  HIỆN TẠI:

                  Chưa tích hợp thư viện âm lịch nên phần này
                  vẫn dùng ngày đang được chọn.

                  Sau này chúng ta sẽ chuyển:
                  Dương lịch -> Âm lịch chính xác.
                */
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 70,
                    height: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Tháng $month',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Lịch Phật giáo',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHÁP CÚ
  // ============================================================

  Widget _buildQuoteSection() {
    return Container(
      width: double.infinity,
      color: backgroundLight,
      padding: const EdgeInsets.symmetric(
        vertical: 48,
        horizontal: 30,
      ),

      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.local_florist,
            size: 180,
            color: primaryBrown.withValues(
              alpha: 0.06,
            ),
          ),

          const Column(
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
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 22),

              Text(
                'Trích Kinh Pháp Cú '
                '(Phẩm Phóng Dật)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KHÁM PHÁ CHÙA
  // ============================================================

  Widget _buildTempleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Khám phá chùa',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Icon(
                Icons.temple_buddhist_outlined,
                color: primaryBrown,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Text(
            'Quét mã QR tại chùa để xem thông tin chi tiết.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 165,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            children: [
              _templeCard(
                icon: Icons.temple_buddhist,
                title: 'Chùa Giác Lâm',
                subtitle: 'TP. Hồ Chí Minh',
              ),

              _templeCard(
                icon: Icons.temple_buddhist,
                title: 'Chùa Vĩnh Nghiêm',
                subtitle: 'TP. Hồ Chí Minh',
              ),

              _templeCard(
                icon: Icons.qr_code_scanner,
                title: 'Quét QR',
                subtitle: 'Khám phá thêm',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _templeCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(
        right: 13,
      ),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1DFBF),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: lightBrown,
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: primaryBrown,
              size: 27,
            ),
          ),

          const Spacer(),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HÀM HỖ TRỢ
  // ============================================================

  bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ Hai';

      case DateTime.tuesday:
        return 'Thứ Ba';

      case DateTime.wednesday:
        return 'Thứ Tư';

      case DateTime.thursday:
        return 'Thứ Năm';

      case DateTime.friday:
        return 'Thứ Sáu';

      case DateTime.saturday:
        return 'Thứ Bảy';

      case DateTime.sunday:
        return 'Chủ Nhật';

      default:
        return '';
    }
  }
}