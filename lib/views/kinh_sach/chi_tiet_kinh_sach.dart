import 'package:flutter/material.dart';

import '../../models/scripture.dart';
import '../../services/scripture_service.dart';
import 'chi_tiet_kinh_sach.dart';

class ChiTietKinhSachPage
    extends StatefulWidget {
  final Scripture scripture;

  const ChiTietKinhSachPage({
    super.key,
    required this.scripture,
  });

  @override
  State<ChiTietKinhSachPage>
      createState() =>
          _ChiTietKinhSachPageState();
}

class _ChiTietKinhSachPageState
    extends State<ChiTietKinhSachPage> {
  static const Color primaryBrown =
      Color(0xFFA56A12);

  double _fontSize = 18;

  void _increaseFont() {
    if (_fontSize >= 26) {
      return;
    }

    setState(() {
      _fontSize += 2;
    });
  }

  void _decreaseFont() {
    if (_fontSize <= 14) {
      return;
    }

    setState(() {
      _fontSize -= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scripture =
        widget.scripture;

    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFCF8),

      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFFFFFCF8,
        ),

        elevation: 0,

        surfaceTintColor:
            Colors.transparent,

        title: Text(
          scripture.type,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            tooltip:
                'Giảm cỡ chữ',

            onPressed:
                _decreaseFont,

            icon:
                const Icon(
              Icons
                  .text_decrease_rounded,
            ),
          ),

          IconButton(
            tooltip:
                'Tăng cỡ chữ',

            onPressed:
                _increaseFont,

            icon:
                const Icon(
              Icons
                  .text_increase_rounded,
            ),
          ),
        ],
      ),

      body: SelectionArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            50,
          ),

          children: [
            Container(
              width: 64,
              height: 64,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFFFE9C5,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  18,
                ),
              ),

              child: Icon(
                scripture.type ==
                        'Chú'
                    ? Icons
                        .spa_rounded
                    : Icons
                        .menu_book_rounded,

                color:
                    primaryBrown,

                size: 32,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              scripture.title,

              style:
                  const TextStyle(
                fontSize: 30,

                fontWeight:
                    FontWeight.w700,

                height: 1.25,

                color:
                    Color(
                  0xFF2D2D2D,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              alignment:
                  Alignment.centerLeft,

              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFFE9C5,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),

                child: Text(
                  scripture.type,

                  style:
                      const TextStyle(
                    color:
                        primaryBrown,

                    fontWeight:
                        FontWeight.w600,

                    fontSize: 12,
                  ),
                ),
              ),
            ),

            if (scripture
                .description
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 22,
              ),

              Text(
                scripture.description,

                style:
                    TextStyle(
                  fontSize: 15,

                  height: 1.6,

                  color:
                      Colors.grey
                          .shade700,

                  fontStyle:
                      FontStyle
                          .italic,
                ),
              ),
            ],

            const SizedBox(
              height: 26,
            ),

            Divider(
              color:
                  Colors.grey
                      .shade300,
            ),

            const SizedBox(
              height: 22,
            ),

            if (scripture
                .content
                .trim()
                .isEmpty)
              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 30,
                ),

                child: Center(
                  child: Text(
                    'Nội dung đang được cập nhật.',
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ),
              )
            else
              SelectableText(
                scripture.content,

                style:
                    TextStyle(
                  fontSize:
                      _fontSize,

                  height: 1.9,

                  letterSpacing:
                      0.1,

                  color:
                      const Color(
                    0xFF333333,
                  ),
                ),
              ),

            if (scripture
                .source
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 40,
              ),

              Divider(
                color:
                    Colors.grey
                        .shade300,
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const Icon(
                    Icons
                        .info_outline_rounded,

                    size: 18,

                    color:
                        Colors.grey,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child: Text(
                      'Nguồn: ${scripture.source}',

                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}