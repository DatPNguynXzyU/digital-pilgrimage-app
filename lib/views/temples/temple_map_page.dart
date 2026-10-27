import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../models/temple.dart';
import '../../services/nearby_temples.dart';
import '../../services/temple_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/folk_art_image.dart';
import 'chi_tiet_chua.dart';
import 'temple_list_page.dart';

class TempleMapPage extends StatefulWidget {
  const TempleMapPage({super.key});

  @override
  State<TempleMapPage> createState() => _TempleMapPageState();
}

class _TempleMapPageState extends State<TempleMapPage> {
  final _service = TempleService();
  late Future<List<Temple>> _temples;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _temples = _service.getTemples();
  }

  Future<void> _openNearby() async {
    setState(() => _locating = true);
    try {
      final position = await NearbyTemples.locate();
      final uri = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': 'chùa gần ${position.latitude},${position.longitude}',
      });
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Không thể mở ứng dụng bản đồ.');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _openTempleMap(Temple temple) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${temple.latitude},${temple.longitude}',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng bản đồ.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppHeader(title: const Text('Bản đồ chùa')),
    body: FutureBuilder<List<dynamic>>(
      future: _temples,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _MapEmpty(
            message: 'Chưa tải được vị trí chùa. Hãy thử lại khi có kết nối.',
          );
        }
        final located = (snapshot.data ?? const [])
            .where(
              (temple) => temple.latitude != null && temple.longitude != null,
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              height: 206,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const FolkArtImage(
                name: 'hand-drawn-map',
                semanticLabel: 'Bản đồ vẽ tay với ghim địa điểm',
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Mở đường đến chốn an yên',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vị trí chỉ được yêu cầu khi bạn chọn tìm quanh đây để Maps tập trung vào khu vực hiện tại. Điểm đến chùa chỉ mở khi dữ liệu có tọa độ.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _locating ? null : _openNearby,
              icon: const Icon(Icons.my_location_rounded),
              label: Text(
                _locating ? 'Đang lấy vị trí…' : 'Tìm chùa quanh tôi trên Maps',
              ),
            ),
            const SizedBox(height: 18),
            if (located.isEmpty)
              const _MapEmpty(
                message: 'Danh sách hiện chưa có tọa độ chùa. Bạn vẫn có thể tìm chùa theo tên và địa chỉ.',
              ),
            if (located.isNotEmpty) ...[
              const Text(
                'Chùa có tọa độ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...located.map(
                (temple) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.surface,
                      child: Icon(Icons.location_on_outlined),
                    ),
                    title: Text(temple.name),
                    subtitle: Text(
                      temple.fullAddress.isEmpty
                          ? 'Tọa độ đã có trong dữ liệu'
                          : temple.fullAddress,
                    ),
                    trailing: IconButton(
                      tooltip: 'Mở đường đi',
                      onPressed: () => _openTempleMap(temple),
                      icon: const Icon(Icons.directions_rounded),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ChiTietChuaPage(temple: temple),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const TempleListPage()),
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Mở danh sách chùa'),
            ),
          ],
        );
      },
    ),
  );
}

class _MapEmpty extends StatelessWidget {
  final String message;
  const _MapEmpty({required this.message});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
    ),
  );
}
