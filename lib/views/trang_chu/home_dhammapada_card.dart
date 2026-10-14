import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class HomeDhammapadaCard extends StatelessWidget {
  const HomeDhammapadaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('dhammapada-card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: AppTheme.secondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kinh Pháp Cú',
                  style: TextStyle(
                    color: AppTheme.warmBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Các câu kinh ý nghĩa sẽ được cập nhật tại đây.',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: AppTheme.textSecondary,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'ĐANG CẬP NHẬT',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
