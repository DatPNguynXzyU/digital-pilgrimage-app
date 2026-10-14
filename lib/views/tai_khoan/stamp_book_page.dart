import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/temple_stamp.dart';
import '../../services/pilgrimage_service.dart';

class StampBookPage extends StatefulWidget {
  final String token;

  const StampBookPage({super.key, required this.token});

  @override
  State<StampBookPage> createState() => _StampBookPageState();
}

class _StampBookPageState extends State<StampBookPage> {
  final PilgrimageService _service = PilgrimageService();
  late Future<List<TempleStamp>> _stampsFuture;

  @override
  void initState() {
    super.initState();
    _loadStamps();
  }

  void _loadStamps() {
    _stampsFuture = _service.getTempleStamps(widget.token);
  }

  Future<void> _refresh() async {
    setState(_loadStamps);
    await _stampsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Sổ tem hành hương')),
      body: FutureBuilder<List<TempleStamp>>(
        future: _stampsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final stamps = snapshot.data ?? const <TempleStamp>[];
          if (stamps.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  const Icon(
                    Icons.local_activity_outlined,
                    size: 54,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sổ tem đang chờ dấu ấn đầu tiên',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tem chỉ được hiển thị sau khi máy chủ xác nhận '
                    'đủ điều kiện nhận.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                _buildIntro(stamps.length),
                const SizedBox(height: 18),
                ...stamps.map(_buildStampCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntro(int count) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_activity_outlined,
            color: AppTheme.secondary,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count dấu ấn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kỷ niệm những chuyến viếng chùa của bạn',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStampCard(TempleStamp stamp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.secondary, width: 1.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 168,
              width: double.infinity,
              child: stamp.thumbnail.trim().isEmpty
                  ? _imagePlaceholder()
                  : Image.network(
                      stamp.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagePlaceholder(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.temple_buddhist_outlined,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stamp.templeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Nhận tem: ${_formatDate(stamp.receivedAt)}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
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
      ),
    );
  }

  Widget _buildError(String message) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 14),
          const Text(
            'Không thể tải sổ tem',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: () => setState(_loadStamps),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppTheme.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.temple_buddhist_outlined,
        color: AppTheme.secondary,
        size: 58,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa cập nhật';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}
