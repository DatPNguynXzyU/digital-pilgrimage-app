import 'package:flutter/material.dart';

import '../../models/pilgrimage_stats.dart';
import '../../models/visited_temple.dart';
import '../../services/pilgrimage_service.dart';

class PilgrimagePage
    extends StatefulWidget {
  final String token;

  const PilgrimagePage({
    super.key,
    required this.token,
  });

  @override
  State<PilgrimagePage> createState() =>
      _PilgrimagePageState();
}

class _PilgrimagePageState
    extends State<PilgrimagePage> {
  static const Color primaryBrown =
      Color(0xFFA56A12);

  final PilgrimageService service =
      PilgrimageService();

  PilgrimageStats? stats;

  List<VisitedTemple> temples = [];

  bool loading = true;

  String selectedSort =
      'most_visited';

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        loading = true;
      });

      final statsResult =
          await service.getStats(
        widget.token,
      );

      final templesResult =
          await service.getVisitedTemples(
        widget.token,
        sort: selectedSort,
      );

      if (!mounted) return;

      setState(() {
        stats = statsResult;
        temples = templesResult;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _changeSort(
    String? value,
  ) async {
    if (value == null) return;

    setState(() {
      selectedSort = value;
    });

    await _loadData();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hành trình của tôi',
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadData,

              child: ListView(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                children: [
                  _buildStats(),

                  const SizedBox(
                    height: 24,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      const Text(
                        'Chùa đã đi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      DropdownButton<
                          String>(
                        value:
                            selectedSort,

                        onChanged:
                            _changeSort,

                        items: const [
                          DropdownMenuItem(
                            value:
                                'most_visited',
                            child: Text(
                              'Đi nhiều nhất',
                            ),
                          ),

                          DropdownMenuItem(
                            value:
                                'recent',
                            child: Text(
                              'Gần đây',
                            ),
                          ),

                          DropdownMenuItem(
                            value:
                                'least_visited',
                            child: Text(
                              'Đi ít nhất',
                            ),
                          ),

                          DropdownMenuItem(
                            value:
                                'name_asc',
                            child: Text(
                              'Tên A-Z',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (temples.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.all(
                        30,
                      ),
                      child: Center(
                        child: Text(
                          'Bạn chưa viếng chùa nào.',
                        ),
                      ),
                    ),

                  ...temples.map(
                    _buildTempleCard,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStats() {
    final data = stats;

    if (data == null) {
      return const SizedBox();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon:
                    Icons.temple_buddhist,
                number:
                    data.uniqueTemples,
                label:
                    'Chùa đã đi',
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _statCard(
                icon:
                    Icons.directions_walk,
                number:
                    data.totalVisits,
                label:
                    'Lượt viếng',
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _statCard(
                icon:
                    Icons.verified,
                number:
                    data.totalStamps,
                label:
                    'Tem đã nhận',
              ),
            ),
          ],
        ),

        if (data
                .mostVisitedTempleName !=
            null) ...[
          const SizedBox(
            height: 16,
          ),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor:
                    primaryBrown,

                child: Icon(
                  Icons
                      .emoji_events_outlined,
                  color:
                      Colors.white,
                ),
              ),

              title: const Text(
                'Chùa đi nhiều nhất',
              ),

              subtitle: Text(
                data
                    .mostVisitedTempleName!,
              ),

              trailing: Text(
                '${data.mostVisitedCount} lần',
                style: const TextStyle(
                  color:
                      primaryBrown,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required int number,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: primaryBrown,
              size: 28,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              number.toString(),

              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              label,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempleCard(
    VisitedTemple temple,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              const Color(
            0xFFF5E8D4,
          ),

          child: const Icon(
            Icons.temple_buddhist,
            color: primaryBrown,
          ),
        ),

        title: Text(
          temple.name,

          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        subtitle: Text(
          'Lần gần nhất: '
          '${_formatDate(temple.lastVisitedAt)}',
        ),

        trailing: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color:
                const Color(
              0xFFF5E8D4,
            ),

            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),

          child: Text(
            '${temple.visitCount} lần',

            style: const TextStyle(
              color: primaryBrown,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(
    DateTime? date,
  ) {
    if (date == null) {
      return 'Chưa rõ';
    }

    final local =
        date.toLocal();

    final day =
        local.day
            .toString()
            .padLeft(2, '0');

    final month =
        local.month
            .toString()
            .padLeft(2, '0');

    return '$day/$month/${local.year}';
  }
}