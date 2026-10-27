import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../widgets/folk_art_image.dart';
import '../../utils/lunar_calendar.dart';

class FolkHomeHero extends StatelessWidget {
  const FolkHomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final now = DateTime.now();
    final lunar = LunarCalendar.fromSolar(now);
    return AspectRatio(
      aspectRatio: width < 380 ? 1.28 : 1.48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const FolkArtImage(
              name: 'pagoda-hero',
              fit: BoxFit.cover,
              semanticLabel: 'Chùa Việt bên hồ sen và núi xanh',
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 128,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDDF7F1E5)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 14,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'CHỐN AN NHIÊN',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tìm một chốn\nan yên',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontSize: 25,
                            height: 1.02,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    key: const ValueKey('hero-date-card'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9EF),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${now.day}/${now.month}/${now.year}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Âm ${lunar.day}/${lunar.month}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
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
}
