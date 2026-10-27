import '../../widgets/temple_photo_album.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../models/temple.dart';
import '../../widgets/saved_item_buttons.dart';

class ChiTietChuaPage extends StatelessWidget {
  final Temple temple;

  const ChiTietChuaPage({super.key, required this.temple});

  static const Color primaryBrown = AppTheme.primary;
  static const Color lightBrown = AppTheme.surface;

  Future<void> _openGoogleMaps(BuildContext context) async {
    final latitude = temple.latitude;
    final longitude = temple.longitude;
    final hasValidCoordinates =
        latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
    if (!hasValidCoordinates) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chùa chưa có tọa độ đã xác minh để tạo chỉ đường.'),
        ),
      );
      return;
    }
    final destination = '$latitude,$longitude';

    final mapsAppUri = Uri.parse(
      'google.navigation:q=${Uri.encodeQueryComponent(destination)}&mode=d',
    );
    final mapsWebUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
    });

    try {
      if (await launchUrl(mapsAppUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } on PlatformException {
      // Fall back to the HTTPS URL if the Google Maps app cannot be opened.
    }

    try {
      if (await launchUrl(mapsWebUri, mode: LaunchMode.externalApplication)) {
        return;
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở Google Maps hoặc trình duyệt.'),
        ),
      );
    } on PlatformException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể mở Google Maps: ${error.message ?? error.code}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            actions: [SaveItemButton(id: temple.id, temple: true)],

            flexibleSpace: FlexibleSpaceBar(
              background: TemplePhotoAlbum(
                images: [temple.thumbnail, ...temple.images],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBrown.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.temple_buddhist_outlined,
                          color: AppTheme.secondary,
                          size: 28,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          temple.name,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: primaryBrown,
                            ),

                            const SizedBox(width: 7),

                            Expanded(
                              child: Text(
                                temple.fullAddress,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        _detailRow(
                          Icons.schedule_outlined,
                          'Giờ ghi nhận: ${temple.openingHoursText}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: lightBrown,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_outlined, color: primaryBrown),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Thông tin do hệ thống tổng hợp. Giờ mở cửa và tọa độ '
                            'cần được xác nhận trực tiếp với tự viện.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (temple.description.trim().isNotEmpty ||
                      temple.history.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (temple.description.trim().isNotEmpty)
                            _contentSection(
                              'Giới thiệu',
                              temple.description,
                              Icons.auto_stories_outlined,
                            ),
                          if (temple.description.trim().isNotEmpty &&
                              temple.history.trim().isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, color: AppTheme.border),
                            ),
                          if (temple.history.trim().isNotEmpty)
                            _contentSection(
                              'Lịch sử',
                              temple.history,
                              Icons.history_edu_outlined,
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () => _openGoogleMaps(context),
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text(
                        'Chỉ đường bằng Google Maps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.secondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmBrown,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.secondary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
