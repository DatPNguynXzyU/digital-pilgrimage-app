import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/temple.dart';
import '../nfc/nfc_scan_page.dart';

class ChiTietChuaPage extends StatelessWidget {
  final Temple temple;

  const ChiTietChuaPage({super.key, required this.temple});

  static const Color primaryBrown = AppTheme.primary;
  static const Color lightBrown = AppTheme.surface;

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

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (temple.thumbnail.trim().isNotEmpty)
                    Image.network(
                      temple.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagePlaceholder(),
                    )
                  else
                    _imagePlaceholder(),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temple.name,
                    style: const TextStyle(
                      fontSize: 28,
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

                  const SizedBox(height: 25),

                  _detailRow(
                    Icons.schedule_outlined,
                    'Giờ mở cửa: ${temple.openingHoursText}',
                  ),

                  if (temple.images.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    const Text(
                      'Hình ảnh',
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGallery(),
                  ],

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
                            'Thông tin được cung cấp bởi hệ thống '
                            'Hành Hương Số',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Giới thiệu',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    temple.description,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Lịch sử',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    temple.history,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const NfcScanPage(),
                          ),
                        );
                      },

                      icon: const Icon(Icons.nfc_rounded),

                      label: const Text(
                        'Check-in bằng NFC',
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

  Widget _imagePlaceholder() {
    return Container(
      color: AppTheme.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.temple_buddhist_outlined,
        size: 100,
        color: AppTheme.secondary,
      ),
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

  Widget _buildGallery() {
    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: temple.images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              temple.images[index],
              width: 210,
              height: 145,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _imagePlaceholder(),
            ),
          );
        },
      ),
    );
  }
}
