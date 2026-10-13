import 'package:flutter/material.dart';

import '../../models/buddhist_figure.dart';

class BuddhistFigureDetailPage
    extends StatelessWidget {
  final BuddhistFigure figure;

  const BuddhistFigureDetailPage({
    super.key,
    required this.figure,
  });

  static const Color primaryBrown =
      Color(0xFFA56A12);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFFFFBF7,
      ),

      appBar: AppBar(
        title: Text(
          figure.name,
        ),

        backgroundColor:
            const Color(
          0xFFFFFBF7,
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Center(
              child: Container(
                width: 130,
                height: 130,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFF3E1C5,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    const Icon(
                  Icons
                      .self_improvement,
                  size: 70,
                  color:
                      primaryBrown,
                ),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            Center(
              child: Text(
                figure.name,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 26,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            if (figure
                .sanskritName
                .isNotEmpty)
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 5,
                  ),

                  child: Text(
                    figure
                        .sanskritName,

                    style:
                        const TextStyle(
                      color:
                          Colors.grey,

                      fontStyle:
                          FontStyle.italic,
                    ),
                  ),
                ),
              ),

            if (figure
                .otherNames
                .isNotEmpty)
              _section(
                'Tên gọi khác',
                figure
                    .otherNames
                    .join(', '),
              ),

            if (figure
                .description
                .isNotEmpty)
              _section(
                'Giới thiệu',
                figure.description,
              ),

            if (figure
                .biography
                .isNotEmpty)
              _section(
                'Tiểu sử',
                figure.biography,
              ),

            if (figure
                .symbolism
                .isNotEmpty)
              _section(
                'Ý nghĩa',
                figure.symbolism,
              ),

            if (figure
                .appearance
                .isNotEmpty)
              _section(
                'Hình tượng',
                figure.appearance,
              ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    String title,
    String content,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 24,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style:
                const TextStyle(
              fontSize: 19,

              fontWeight:
                  FontWeight.bold,

              color:
                  primaryBrown,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            content,

            textAlign:
                TextAlign.justify,

            style:
                const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}