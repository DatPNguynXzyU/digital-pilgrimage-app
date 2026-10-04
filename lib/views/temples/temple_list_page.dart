import 'package:flutter/material.dart';

import '../../models/temple.dart';
import '../../services/temple_service.dart';

class TempleListPage
    extends StatefulWidget {
  const TempleListPage({
    super.key,
  });

  @override
  State<TempleListPage>
      createState() =>
          _TempleListPageState();
}

class _TempleListPageState
    extends State<TempleListPage> {
  final TempleService
      _templeService =
      TempleService();

  late Future<List<Temple>>
      _templesFuture;

  @override
  void initState() {
    super.initState();

    _loadTemples();
  }

  void _loadTemples() {
    _templesFuture =
        _templeService.getTemples();
  }

  Future<void> _refresh()
      async {
    setState(() {
      _loadTemples();
    });

    await _templesFuture;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Chùa',
        ),
      ),

      body:
          FutureBuilder<
              List<Temple>>(
        future:
            _templesFuture,

        builder:
            (
          context,
          snapshot,
        ) {
          if (
              snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
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
                          .error_outline,
                      size: 48,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      snapshot.error
                          .toString(),
                      textAlign:
                          TextAlign
                              .center,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        setState(
                          () {
                            _loadTemples();
                          },
                        );
                      },

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

          final temples =
              snapshot.data ?? [];

          if (temples.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu chùa.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh:
                _refresh,

            child:
                ListView.builder(
              padding:
                  const EdgeInsets.all(
                16,
              ),

              itemCount:
                  temples.length,

              itemBuilder:
                  (
                context,
                index,
              ) {
                final temple =
                    temples[index];

                return Card(
                  margin:
                      const EdgeInsets
                          .only(
                    bottom: 16,
                  ),

                  clipBehavior:
                      Clip.antiAlias,

                  child:
                      InkWell(
                    onTap: () {
                      // Sau này mở
                      // TempleDetailPage
                    },

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        if (temple
                            .thumbnail
                            .isNotEmpty)
                          AspectRatio(
                            aspectRatio:
                                16 /
                                    9,

                            child:
                                Image.network(
                              temple
                                  .thumbnail,

                              fit: BoxFit
                                  .cover,

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Center(
                                  child:
                                      Icon(
                                    Icons
                                        .temple_buddhist,
                                    size:
                                        60,
                                  ),
                                );
                              },
                            ),
                          ),

                        Padding(
                          padding:
                              const EdgeInsets
                                  .all(
                            16,
                          ),

                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                temple
                                    .name,

                                style:
                                    Theme.of(
                                  context,
                                )
                                        .textTheme
                                        .titleLarge,
                              ),

                              const SizedBox(
                                height:
                                    8,
                              ),

                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  const Icon(
                                    Icons
                                        .location_on_outlined,
                                    size:
                                        18,
                                  ),

                                  const SizedBox(
                                    width:
                                        6,
                                  ),

                                  Expanded(
                                    child:
                                        Text(
                                      temple
                                          .fullAddress,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height:
                                    8,
                              ),

                              Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .schedule,
                                    size:
                                        18,
                                  ),

                                  const SizedBox(
                                    width:
                                        6,
                                  ),

                                  Text(
                                    temple
                                        .openingHoursText,
                                  ),
                                ],
                              ),

                              if (temple
                                  .description
                                  .isNotEmpty) ...[
                                const SizedBox(
                                  height:
                                      12,
                                ),

                                Text(
                                  temple
                                      .description,

                                  maxLines:
                                      2,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}