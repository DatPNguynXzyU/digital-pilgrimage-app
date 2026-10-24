import '../../widgets/content_thumbnail.dart';

import 'package:flutter/material.dart';

import '../../models/buddhist_figure.dart';

class BuddhistFigureDetailPage extends StatelessWidget {
  final BuddhistFigure figure;

  const BuddhistFigureDetailPage({super.key, required this.figure});

  static const Color primaryBrown = Color(0xFFA56A12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),

      appBar: AppBar(
        title: Text(figure.name),

        backgroundColor: const Color(0xFFFFFBF7),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E1C5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBrown.withValues(alpha: 0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ContentThumbnail(
                        url: figure.thumbnail,
                        icon: Icons.self_improvement,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Center(
              child: Text(
                figure.name,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 26,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (figure.sanskritName.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),

                  child: Text(
                    figure.sanskritName,

                    style: const TextStyle(
                      color: Colors.grey,

                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            if (figure.otherNames.isNotEmpty ||
                figure.description.trim().isNotEmpty ||
                figure.biography.trim().isNotEmpty ||
                figure.symbolism.trim().isNotEmpty ||
                figure.appearance.trim().isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE6DCCB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (figure.otherNames.isNotEmpty)
                      _section('Tên gọi khác', figure.otherNames.join(', ')),

                    if (figure.description.isNotEmpty)
                      _section('Giới thiệu', figure.description),

                    if (figure.biography.isNotEmpty)
                      _section('Tiểu sử', figure.biography),

                    if (figure.symbolism.isNotEmpty)
                      _section('Ý nghĩa', figure.symbolism),

                    if (figure.appearance.isNotEmpty)
                      _section('Hình tượng', figure.appearance),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              fontSize: 17,

              fontWeight: FontWeight.bold,

              color: primaryBrown,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            content,

            textAlign: TextAlign.start,

            style: const TextStyle(fontSize: 16, height: 1.45),
          ),
        ],
      ),
    );
  }
}
