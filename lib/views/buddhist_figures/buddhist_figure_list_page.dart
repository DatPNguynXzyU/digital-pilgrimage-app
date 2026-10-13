import 'package:flutter/material.dart';

import '../../models/buddhist_figure.dart';
import '../../services/buddhist_figure_service.dart';
import 'buddhist_figure_detail_page.dart';

class BuddhistFigureListPage
    extends StatefulWidget {
  const BuddhistFigureListPage({
    super.key,
  });

  @override
  State<BuddhistFigureListPage>
      createState() =>
          _BuddhistFigureListPageState();
}

class _BuddhistFigureListPageState
    extends State<BuddhistFigureListPage> {
  static const Color primaryBrown =
      Color(0xFFA56A12);

  final BuddhistFigureService
      _service =
      BuddhistFigureService();

  final TextEditingController
      _searchController =
      TextEditingController();

  bool _loading = true;

  List<BuddhistFigure> _figures = [];

  String _category = 'all';

  @override
  void initState() {
    super.initState();

    _loadFigures();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadFigures() async {
    try {
      setState(() {
        _loading = true;
      });

      final result =
          await _service.getFigures(
        search:
            _searchController.text,

        category:
            _category,
      );

      if (!mounted) return;

      setState(() {
        _figures = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  String _categoryName(
    String category,
  ) {
    switch (category) {
      case 'buddha':
        return 'Phật';

      case 'bodhisattva':
        return 'Bồ Tát';

      case 'arhat':
        return 'La Hán';

      case 'patriarch':
        return 'Tổ sư';

      case 'guardian':
        return 'Hộ Pháp';

      default:
        return 'Khác';
    }
  }

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
        title: const Text(
          'Phật & Bồ Tát',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(
          0xFFFFFBF7,
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),

            child: TextField(
              controller:
                  _searchController,

              onSubmitted: (_) =>
                  _loadFigures(),

              decoration:
                  InputDecoration(
                hintText:
                    'Tìm tên...',

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    IconButton(
                  onPressed:
                      _loadFigures,

                  icon:
                      const Icon(
                    Icons.search,
                  ),
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Row(
              children: [
                _categoryChip(
                  'all',
                  'Tất cả',
                ),

                _categoryChip(
                  'buddha',
                  'Phật',
                ),

                _categoryChip(
                  'bodhisattva',
                  'Bồ Tát',
                ),

                _categoryChip(
                  'arhat',
                  'La Hán',
                ),

                _categoryChip(
                  'patriarch',
                  'Tổ sư',
                ),

                _categoryChip(
                  'guardian',
                  'Hộ Pháp',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          primaryBrown,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh:
                        _loadFigures,

                    child:
                        _figures.isEmpty
                            ? ListView(
                                children:
                                    const [
                                  SizedBox(
                                    height:
                                        180,
                                  ),

                                  Icon(
                                    Icons
                                        .search_off,
                                    size:
                                        60,
                                    color:
                                        Colors
                                            .grey,
                                  ),

                                  SizedBox(
                                    height:
                                        12,
                                  ),

                                  Center(
                                    child:
                                        Text(
                                      'Không tìm thấy dữ liệu.',
                                    ),
                                  ),
                                ],
                              )
                            : ListView
                                .builder(
                                padding:
                                    const EdgeInsets
                                        .all(
                                  16,
                                ),

                                itemCount:
                                    _figures
                                        .length,

                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  final figure =
                                      _figures[
                                          index];

                                  return Card(
                                    margin:
                                        const EdgeInsets
                                            .only(
                                      bottom:
                                          12,
                                    ),

                                    child:
                                        ListTile(
                                      contentPadding:
                                          const EdgeInsets
                                              .all(
                                        12,
                                      ),

                                      leading:
                                          const CircleAvatar(
                                        radius:
                                            28,

                                        backgroundColor:
                                            Color(
                                          0xFFF3E1C5,
                                        ),

                                        child:
                                            Icon(
                                          Icons
                                              .self_improvement,
                                          color:
                                              primaryBrown,
                                        ),
                                      ),

                                      title:
                                          Text(
                                        figure
                                            .name,

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      subtitle:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [
                                          if (figure
                                              .sanskritName
                                              .isNotEmpty)
                                            Text(
                                              figure
                                                  .sanskritName,
                                            ),

                                          Text(
                                            _categoryName(
                                              figure
                                                  .category,
                                            ),
                                          ),
                                        ],
                                      ),

                                      trailing:
                                          const Icon(
                                        Icons
                                            .chevron_right,
                                      ),

                                      onTap:
                                          () {
                                        Navigator
                                            .push(
                                          context,

                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    BuddhistFigureDetailPage(
                                              figure:
                                                  figure,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(
    String value,
    String label,
  ) {
    final selected =
        _category == value;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child: ChoiceChip(
        label: Text(label),

        selected:
            selected,

        onSelected: (_) {
          setState(() {
            _category = value;
          });

          _loadFigures();
        },
      ),
    );
  }
}