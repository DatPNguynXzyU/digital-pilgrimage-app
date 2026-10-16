import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/pilgrimage_stats.dart';
import '../../models/visited_temple.dart';
import '../../services/pilgrimage_favorites_store.dart';
import '../../services/pilgrimage_service.dart';

class PilgrimagePage extends StatefulWidget {
  final String token;

  const PilgrimagePage({super.key, required this.token});

  @override
  State<PilgrimagePage> createState() => _PilgrimagePageState();
}

class _PilgrimagePageState extends State<PilgrimagePage> {
  static const Color primaryBrown = AppTheme.primary;
  final PilgrimageService service = PilgrimageService();
  final PilgrimageFavoritesStore _favoritesStore = PilgrimageFavoritesStore();
  final Set<String> _favoriteTempleIds = {};
  final Set<String> _updatingFavoriteIds = {};

  PilgrimageStats? stats;

  List<VisitedTemple> temples = [];

  bool loading = true;

  String selectedSort = 'most_visited';

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        loading = true;
      });

      final favorites = await _favoritesStore.load();
      final statsResult = await service.getStats(widget.token);

      final templesResult = await service.getVisitedTemples(
        widget.token,
        sort: selectedSort == 'favorites' ? 'most_visited' : selectedSort,
      );

      if (!mounted) return;

      setState(() {
        stats = statsResult;
        temples = templesResult;
        _favoriteTempleIds
          ..clear()
          ..addAll(favorites);
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _changeSort(String? value) async {
    if (value == null) return;

    setState(() {
      selectedSort = value;
    });

    await _loadData();
  }

  String _favoriteKey(VisitedTemple temple) =>
      temple.id.isNotEmpty ? temple.id : temple.slug;

  Future<void> _toggleFavorite(VisitedTemple temple) async {
    final id = _favoriteKey(temple);
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu yêu thích: thiếu mã định danh chùa.'),
        ),
      );
      return;
    }
    if (_updatingFavoriteIds.isNotEmpty) return;
    setState(() => _updatingFavoriteIds.add(id));

    try {
      final isFavorite = await _favoritesStore.toggle(id);
      if (!mounted) return;
      setState(() {
        if (isFavorite) {
          _favoriteTempleIds.add(id);
        } else {
          _favoriteTempleIds.remove(id);
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật chùa yêu thích: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingFavoriteIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleTemples = selectedSort == 'favorites'
        ? temples
              .where(
                (temple) => _favoriteTempleIds.contains(_favoriteKey(temple)),
              )
              .toList()
        : temples;

    return Scaffold(
      appBar: AppBar(title: const Text('Hành trình của tôi')),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,

              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  _buildStats(),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Chùa đã đi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sort_rounded,
                              color: AppTheme.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Sắp xếp',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedSort,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                ),
                                onChanged: _changeSort,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'most_visited',
                                    child: Text(
                                      'Chùa đi nhiều nhất',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'least_visited',
                                    child: Text(
                                      'Chùa đi ít nhất',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'favorites',
                                    child: Text(
                                      'Chùa yêu thích',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (visibleTemples.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          selectedSort == 'favorites'
                              ? 'Chưa có chùa yêu thích. Hãy nhấn biểu tượng trái tim ở chùa bạn đã đi.'
                              : 'Bạn chưa viếng chùa nào.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  ...visibleTemples.map(_buildTempleCard),
                ],
              ),
            ),
    );
  }

  Widget _buildStats() {
    final data = stats;

    if (data == null) {
      return const SizedBox();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.temple_buddhist,
                number: data.uniqueTemples,
                label: 'Chùa đã đi',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                icon: Icons.directions_walk,
                number: data.totalVisits,
                label: 'Lượt viếng',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                icon: Icons.verified,
                number: data.totalStamps,
                label: 'Tem đã nhận',
              ),
            ),
          ],
        ),

        if (data.mostVisitedTempleName != null) ...[
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: primaryBrown,

                child: Icon(Icons.emoji_events_outlined, color: Colors.white),
              ),

              title: const Text('Chùa đi nhiều nhất'),

              subtitle: Text(data.mostVisitedTempleName!),

              trailing: Text(
                '${data.mostVisitedCount} lần',
                style: const TextStyle(
                  color: primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required int number,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),

        child: Column(
          children: [
            Icon(icon, color: primaryBrown, size: 28),

            const SizedBox(height: 8),

            Text(
              number.toString(),

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            Text(
              label,

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempleCard(VisitedTemple temple) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF5E8D4),

          child: const Icon(Icons.temple_buddhist, color: primaryBrown),
        ),

        title: Text(
          temple.name,

          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          'Lần gần nhất: '
          '${_formatDate(temple.lastVisitedAt)}',
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E8D4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${temple.visitCount} lần',
                style: const TextStyle(
                  color: primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: _favoriteTempleIds.contains(_favoriteKey(temple))
                  ? 'Bỏ yêu thích'
                  : 'Thêm vào yêu thích',
              onPressed: _updatingFavoriteIds.isNotEmpty
                  ? null
                  : () => _toggleFavorite(temple),
              icon: Icon(
                _favoriteTempleIds.contains(_favoriteKey(temple))
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _favoriteTempleIds.contains(_favoriteKey(temple))
                    ? AppTheme.accent
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Chưa rõ';
    }

    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');

    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }
}
