import 'package:flutter/material.dart';

import '../../models/scripture.dart';
import '../../services/scripture_service.dart';
import 'chi_tiet_kinh_sach.dart';

class KinhSachPage extends StatefulWidget {
  const KinhSachPage({super.key});

  @override
  State<KinhSachPage> createState() => _KinhSachPageState();
}

class _KinhSachPageState extends State<KinhSachPage> {
  static const Color primaryBrown = Color(0xFFA56A12);
  static const Color backgroundColor = Color(0xFFFFFCF8);
  static const Color lightBrown = Color(0xFFFFE9C5);

  final ScriptureService _scriptureService = ScriptureService();

  final TextEditingController _searchController =
      TextEditingController();

  late Future<List<Scripture>> _scripturesFuture;

  String _searchKeyword = '';
  String _selectedType = 'Tất cả';

  final List<String> _types = [
    'Tất cả',
    'Kinh',
    'Chú',
  ];

  @override
  void initState() {
    super.initState();

    _scripturesFuture =
        _scriptureService.getScriptures();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _scripturesFuture =
          _scriptureService.getScriptures();
    });

    await _scripturesFuture;
  }

  List<Scripture> _filterScriptures(
    List<Scripture> scriptures,
  ) {
    final keyword =
        _searchKeyword.trim().toLowerCase();

    return scriptures.where((scripture) {
      final matchesSearch =
          keyword.isEmpty ||
          scripture.title
              .toLowerCase()
              .contains(keyword) ||
          scripture.description
              .toLowerCase()
              .contains(keyword);

      final matchesType =
          _selectedType == 'Tất cả' ||
          scripture.type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();
  }

  void _openDetail(
    Scripture scripture,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChiTietKinhSachPage(
          scripture: scripture,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child:
            FutureBuilder<List<Scripture>>(
          future:
              _scripturesFuture,

          builder:
              (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      primaryBrown,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError(
                snapshot.error
                    .toString(),
              );
            }

            final scriptures =
                snapshot.data ?? [];

            final filtered =
                _filterScriptures(
              scriptures,
            );

            return RefreshIndicator(
              color:
                  primaryBrown,

              onRefresh:
                  _reload,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(
                  20,
                ),

                children: [
                  _buildHeader(),

                  const SizedBox(
                    height: 24,
                  ),

                  _buildSearch(),

                  const SizedBox(
                    height: 16,
                  ),

                  _buildFilter(),

                  const SizedBox(
                    height: 26,
                  ),

                  const Text(
                    'Kinh sách',
                    style:
                        TextStyle(
                      fontSize:
                          20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  if (filtered.isEmpty)
                    _buildEmpty()
                  else
                    ...filtered.map(
                      (scripture) =>
                          _buildCard(
                        scripture,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(
          Icons.menu_book_rounded,
          size: 34,
          color: primaryBrown,
        ),

        SizedBox(
          width: 12,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              'Kinh sách',
              style:
                  TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 3,
            ),

            Text(
              'Đọc và tìm hiểu kinh, chú',
              style:
                  TextStyle(
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller:
          _searchController,

      onChanged: (value) {
        setState(() {
          _searchKeyword =
              value;
        });
      },

      decoration:
          InputDecoration(
        hintText:
            'Tìm kiếm kinh, chú...',

        prefixIcon:
            const Icon(
          Icons.search,
          color:
              primaryBrown,
        ),

        suffixIcon:
            _searchKeyword.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController
                          .clear();

                      setState(() {
                        _searchKeyword =
                            '';
                      });
                    },

                    icon:
                        const Icon(
                      Icons.close,
                    ),
                  ),

        filled: true,
        fillColor:
            Colors.white,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return Wrap(
      spacing: 10,

      children:
          _types.map(
        (type) {
          final selected =
              type ==
                  _selectedType;

          return ChoiceChip(
            label:
                Text(type),

            selected:
                selected,

            showCheckmark:
                false,

            selectedColor:
                primaryBrown,

            backgroundColor:
                Colors.white,

            labelStyle:
                TextStyle(
              color:
                  selected
                      ? Colors.white
                      : Colors.black87,

              fontWeight:
                  FontWeight.w600,
            ),

            onSelected: (_) {
              setState(() {
                _selectedType =
                    type;
              });
            },
          );
        },
      ).toList(),
    );
  }

  Widget _buildCard(
    Scripture scripture,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFF1E6D7,
          ),
        ),
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          18,
        ),

        onTap: () {
          _openDetail(
            scripture,
          );
        },

        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),

          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,

                decoration:
                    BoxDecoration(
                  color:
                      lightBrown,

                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),

                child:
                    Icon(
                  scripture.type ==
                          'Chú'
                      ? Icons
                          .spa_rounded
                      : Icons
                          .menu_book_rounded,

                  color:
                      primaryBrown,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      scripture.title,

                      style:
                          const TextStyle(
                        fontSize:
                            16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      scripture
                          .description,

                      maxLines: 2,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        height:
                            1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      scripture.type,

                      style:
                          const TextStyle(
                        color:
                            primaryBrown,

                        fontSize:
                            12,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding:
          EdgeInsets.only(
        top: 70,
      ),

      child: Column(
        children: [
          Icon(
            Icons
                .menu_book_outlined,
            size: 60,
            color:
                Colors.grey,
          ),

          SizedBox(
            height: 16,
          ),

          Text(
            'Không tìm thấy kinh sách',
            style:
                TextStyle(
              color:
                  Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [
            const Icon(
              Icons
                  .cloud_off_rounded,
              size: 60,
              color:
                  Colors.grey,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Không thể tải kinh sách',
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              error,
              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Colors.grey,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            ElevatedButton(
              onPressed:
                  _reload,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryBrown,

                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text(
                'Thử lại',
              ),
            ),
          ],
        ),
      ),
    );
  }
}