import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/pilgrimage_stats.dart';
import '../../models/temple.dart';
import '../../services/auth_service.dart';
import '../../services/pilgrimage_service.dart';
import '../../services/temple_service.dart';
import '../buddhist_figures/buddhist_figure_list_page.dart';
import '../temples/chi_tiet_chua.dart';
import 'home_dhammapada_card.dart';
import 'home_hero.dart';

class TrangChu extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const TrangChu({super.key, this.onNavigate});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  final AuthService _authService = AuthService();
  final PilgrimageService _pilgrimageService = PilgrimageService();
  final TempleService _templeService = TempleService();

  late Future<List<Temple>> _featuredTemples;
  late Future<PilgrimageStats?> _pilgrimageStats;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _featuredTemples = _templeService.getTemples(sort: 'name_asc');
    _pilgrimageStats = _loadStats();
  }

  Future<PilgrimageStats?> _loadStats() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) return null;
    return _pilgrimageService.getStats(token);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await Future.wait([_featuredTemples, _pilgrimageStats]);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 17) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String get _todayLabel {
    final now = DateTime.now();
    return 'Thứ ${now.weekday == DateTime.sunday ? 'Chủ nhật' : now.weekday + 1}, '
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildHero(),
              const SizedBox(height: 28),
              _buildQuoteCard(),
              const SizedBox(height: 28),
              _buildJourneySection(),
              const SizedBox(height: 30),
              _buildTempleSectionHeading(),
              const SizedBox(height: 14),
              _buildFeaturedTemples(),
              const SizedBox(height: 28),
              _buildKnowledgeLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Hành trình an nhiên',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _todayLabel,
                style: const TextStyle(
                  color: AppTheme.warmBrown,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Mở trang cá nhân',
          child: InkWell(
            onTap: () => widget.onNavigate?.call(4),
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() => const HomeHero();

  Widget _buildSectionHeading(String eyebrow, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTempleSectionHeading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildSectionHeading('Ghé thăm', 'Gợi ý chốn bình yên'),
        ),
        const SizedBox(width: 8),
        TextButton(
          key: const ValueKey('see-all-temples'),
          onPressed: () => widget.onNavigate?.call(1),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Xem thêm'),
              SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() => const HomeDhammapadaCard();

  Widget _buildJourneySection() {
    return FutureBuilder<PilgrimageStats?>(
      future: _pilgrimageStats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildJourneyPanel(
            title: 'Hành trình của tôi',
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                color: AppTheme.secondary,
                backgroundColor: AppTheme.surface,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildJourneyPanel(
            title: 'Hành trình của tôi',
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chưa thể tải số liệu hành trình.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _pilgrimageStats = _loadStats();
                  }),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final stats = snapshot.data;
        if (stats == null) {
          return _buildJourneyPanel(
            title: 'Hành trình của tôi',
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Đăng nhập để lưu lại những chặng đường đã đi.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate?.call(4),
                  child: const Text('Đăng nhập'),
                ),
              ],
            ),
          );
        }

        return _buildJourneyPanel(
          title: 'Hành trình của tôi',
          child: Row(
            children: [
              _journeyMetric('${stats.uniqueTemples}', 'ngôi chùa'),
              _metricDivider(),
              _journeyMetric('${stats.totalVisits}', 'lượt viếng'),
              _metricDivider(),
              _journeyMetric('${stats.totalStamps}', 'con dấu'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJourneyPanel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigate?.call(4),
                child: const Text('Chi tiết'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _journeyMetric(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() {
    return Container(width: 1, height: 34, color: AppTheme.border);
  }

  Widget _buildFeaturedTemples() {
    return SizedBox(
      height: 232,
      child: FutureBuilder<List<Temple>>(
        future: _featuredTemples,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return _featuredState(
              icon: Icons.cloud_off_outlined,
              message: 'Chưa thể tải danh sách chùa.',
              actionLabel: 'Thử lại',
              onPressed: () => setState(_reload),
            );
          }

          final temples = (snapshot.data ?? const <Temple>[])
              .where((temple) => temple.isFeatured)
              .take(5)
              .toList();
          if (temples.isEmpty) {
            return _featuredState(
              icon: Icons.temple_buddhist_outlined,
              message: 'Chưa có chùa nổi bật để gợi ý.',
              actionLabel: 'Xem danh sách',
              onPressed: () => widget.onNavigate?.call(1),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: temples.length,
            separatorBuilder: (_, _) => const SizedBox(width: 13),
            itemBuilder: (context, index) =>
                _featuredTempleCard(temples[index]),
          );
        },
      ),
    );
  }

  Widget _featuredTempleCard(Temple temple) {
    return SizedBox(
      width: 250,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ChiTietChuaPage(temple: temple),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: temple.thumbnail.trim().isEmpty
                      ? _templeImagePlaceholder()
                      : Image.network(
                          temple.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _templeImagePlaceholder(),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (temple.fullAddress.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        temple.fullAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _templeImagePlaceholder() {
    return Container(
      color: AppTheme.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.temple_buddhist_outlined,
        color: AppTheme.secondary,
        size: 48,
      ),
    );
  }

  Widget _featuredState({
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondary, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
          ),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }

  Widget _buildKnowledgeLink() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const BuddhistFigureListPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEEE2D5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          children: [
            Icon(Icons.spa_outlined, color: AppTheme.warmBrown, size: 29),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tìm hiểu Phật & Bồ Tát',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Khám phá biểu tượng và câu chuyện',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: AppTheme.warmBrown),
          ],
        ),
      ),
    );
  }
}
