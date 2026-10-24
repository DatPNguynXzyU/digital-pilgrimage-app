import '../../widgets/content_thumbnail.dart';

import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/scripture.dart';
import '../../services/scripture_service.dart';
import '../buddhist_figures/buddhist_figure_list_page.dart';
import 'chi_tiet_kinh_sach.dart';

class KinhSachPage extends StatefulWidget {
  const KinhSachPage({super.key});

  @override
  State<KinhSachPage> createState() => _KinhSachPageState();
}

class _KinhSachPageState extends State<KinhSachPage> {
  static const Color primaryBrown = AppTheme.primary;
  static const Color backgroundColor = AppTheme.background;
  static const Color lightBrown = AppTheme.surface;

  final ScriptureService _scriptureService = ScriptureService();

  final TextEditingController _searchController = TextEditingController();

  late Future<List<Scripture>> _scripturesFuture;

  String _searchKeyword = '';
  String _selectedType = 'Tất cả';

  final List<String> _types = ['Tất cả', 'Kinh', 'Chú'];

  @override
  void initState() {
    super.initState();

    _scripturesFuture = _scriptureService.getScriptures();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _scripturesFuture = _scriptureService.getScriptures();
    });

    await _scripturesFuture;
  }

  List<Scripture> _filterScriptures(List<Scripture> scriptures) {
    final keyword = _searchKeyword.trim().toLowerCase();

    return scriptures.where((scripture) {
      final matchesSearch =
          keyword.isEmpty ||
          scripture.title.toLowerCase().contains(keyword) ||
          scripture.description.toLowerCase().contains(keyword);

      final matchesType =
          _selectedType == 'Tất cả' || scripture.type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();
  }

  void _openDetail(Scripture scripture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChiTietKinhSachPage(scripture: scripture),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<Scripture>>(
          future: _scripturesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: _buildHeader(),
                  ),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: primaryBrown),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: _buildHeader(),
                  ),
                  Expanded(child: _buildError(snapshot.error.toString())),
                ],
              );
            }

            final scriptures = snapshot.data ?? [];
            final filtered = _filterScriptures(scriptures);

            return RefreshIndicator(
              color: primaryBrown,
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearch(),
                  const SizedBox(height: 16),
                  _buildFilter(),
                  const SizedBox(height: 26),
                  const Text(
                    'Kinh sách',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    _buildEmpty()
                  else
                    ...filtered.map((scripture) => _buildCard(scripture)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.menu_book_rounded, size: 34, color: primaryBrown),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kinh sách',
              key: ValueKey('scripture-page-heading'),
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),
            Text(
              'Đọc và tìm hiểu kinh, chú',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      TextButton.icon(
        key: const ValueKey('buddhist-figure-lookup'),
        onPressed: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const BuddhistFigureListPage(),
            ),
          );
        },
        icon: const Icon(Icons.spa_outlined, size: 17),
        label: const Text('Tra cứu chư vị', maxLines: 1, softWrap: false),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.warmBrown,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(0, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    ],
  );

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,

      onChanged: (value) {
        setState(() {
          _searchKeyword = value;
        });
      },

      decoration: InputDecoration(
        hintText: 'Tìm kiếm kinh, chú...',

        prefixIcon: const Icon(Icons.search, color: primaryBrown),

        suffixIcon: _searchKeyword.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchKeyword = '';
                  });
                },

                icon: const Icon(Icons.close),
              ),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return Wrap(
      spacing: 10,

      children: _types.map((type) {
        final selected = type == _selectedType;

        return ChoiceChip(
          label: Text(type),

          selected: selected,

          showCheckmark: false,

          selectedColor: primaryBrown,

          backgroundColor: Colors.white,

          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,

            fontWeight: FontWeight.w600,
          ),

          onSelected: (_) {
            setState(() {
              _selectedType = type;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCard(Scripture scripture) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFF1E6D7)),
        boxShadow: [
          BoxShadow(
            color: primaryBrown.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: () {
          _openDetail(scripture);
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 60,
                height: 82,

                decoration: BoxDecoration(
                  color: lightBrown,

                  borderRadius: BorderRadius.circular(14),
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ContentThumbnail(
                    url: scripture.imageUrl,
                    icon: scripture.type == 'Chú'
                        ? Icons.spa_rounded
                        : Icons.menu_book_rounded,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      scripture.title,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      scripture.description,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(color: Colors.grey, height: 1.4),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      scripture.type,

                      style: const TextStyle(
                        color: primaryBrown,

                        fontSize: 12,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.only(top: 70),

      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 60, color: Colors.grey),

          SizedBox(height: 16),

          Text(
            'Không tìm thấy kinh sách',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey),

            const SizedBox(height: 16),

            const Text(
              'Không thể tải kinh sách',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              error,
              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: _reload,

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,

                foregroundColor: Colors.white,
              ),

              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
