import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/temple.dart';
import '../../services/temple_service.dart';
import '../../widgets/app_header.dart';
import 'chi_tiet_chua.dart';

class TempleSearchPage extends StatefulWidget {
  const TempleSearchPage({super.key});

  @override
  State<TempleSearchPage> createState() => _TempleSearchPageState();
}

class _TempleSearchPageState extends State<TempleSearchPage> {
  final _controller = TextEditingController();
  final _service = TempleService();
  Timer? _debounce;
  Future<List<Temple>>? _results;
  int _requestId = 0;
  String? _cityFilter;

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (value.trim().isEmpty) {
        setState(() => _results = null);
      } else {
        final requestId = ++_requestId;
        setState(() => _results = _findLocally(value.trim(), requestId));
      }
    });
  }

  Future<List<Temple>> _findLocally(String query, int requestId) async {
    final all = await _service.getTemples();
    final needle = query.toLowerCase();
    final matches = all
        .where(
          (temple) => <String>[
            temple.name,
            temple.slug,
            temple.fullAddress,
            temple.description,
          ].any((value) => value.toLowerCase().contains(needle)),
        )
        .toList();
    if (requestId != _requestId) return const <Temple>[];
    return matches;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppHeader(title: const Text('Tìm kiếm chùa')),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: TextField(
              autofocus: true,
              controller: _controller,
              onChanged: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tên chùa, tỉnh thành hoặc địa chỉ',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Xóa nội dung',
                  onPressed: () {
                    _controller.clear();
                    setState(() => _results = null);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          Expanded(
            child: _results == null
                ? const _SearchHint()
                : FutureBuilder<List<Temple>>(
                    future: _results,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const _SearchHint(
                          message: 'Chưa thể tải kết quả. Hãy thử lại sau.',
                        );
                      }
                      final temples = snapshot.data ?? const <Temple>[];
                      final cities =
                          temples
                              .map((temple) => temple.city.trim())
                              .where((city) => city.isNotEmpty)
                              .toSet()
                              .toList()
                            ..sort();
                      final activeCity = cities.contains(_cityFilter)
                          ? _cityFilter
                          : null;
                      final visible = activeCity == null
                          ? temples
                          : temples
                                .where((temple) => temple.city == activeCity)
                                .toList();
                      return Column(
                        children: [
                          if (cities.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                              child: DropdownButtonFormField<String>(
                                initialValue: activeCity ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Lọc theo tỉnh/thành',
                                  prefixIcon: Icon(Icons.filter_alt_outlined),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: '',
                                    child: Text('Tất cả địa điểm'),
                                  ),
                                  ...cities.map(
                                    (city) => DropdownMenuItem(
                                      value: city,
                                      child: Text(city),
                                    ),
                                  ),
                                ],
                                onChanged: (value) => setState(
                                  () => _cityFilter =
                                      value == null || value.isEmpty
                                      ? null
                                      : value,
                                ),
                              ),
                            ),
                          Expanded(
                            child: visible.isEmpty
                                ? const _SearchHint(
                                    message: 'Không tìm thấy chùa phù hợp tại địa điểm đã chọn.',
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      24,
                                    ),
                                    itemCount: visible.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final temple = visible[index];
                                      return Card(
                                        child: ListTile(
                                          minLeadingWidth: 48,
                                          leading: const CircleAvatar(
                                            backgroundColor: AppTheme.surface,
                                            child: Icon(
                                              Icons.temple_buddhist_outlined,
                                            ),
                                          ),
                                          title: Text(
                                            temple.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            temple.fullAddress.isEmpty
                                                ? 'Địa chỉ chưa cập nhật'
                                                : temple.fullAddress,
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (_) => ChiTietChuaPage(
                                                temple: temple,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

class _SearchHint extends StatelessWidget {
  final String message;
  const _SearchHint({
    this.message = 'Tìm theo tên chùa, địa danh hoặc địa chỉ.',
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
    ),
  );
}
