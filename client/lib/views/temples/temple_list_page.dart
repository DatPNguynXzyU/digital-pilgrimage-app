import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/nearby_temples.dart';

import '../../config/app_theme.dart';
import '../../models/temple.dart';
import '../../services/temple_service.dart';
import '../../widgets/saved_item_buttons.dart';
import '../nfc/nfc_scan_page.dart';
import 'chi_tiet_chua.dart';
import '../../widgets/app_header.dart';

class TempleListPage extends StatefulWidget {
  const TempleListPage({super.key});

  @override
  State<TempleListPage> createState() => _TempleListPageState();
}

class _TempleListPageState extends State<TempleListPage> {
  final TempleService _templeService = TempleService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Temple>> _templesFuture;
  Timer? _searchDebounce;
  String _sort = 'name_asc';
  Position? _position;
  bool _locating = false;
  String? _locationError;
  NearbyLocationFailure? _locationFailure;

  @override
  void initState() {
    super.initState();
    _loadTemples();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _loadTemples);
  }

  void _loadTemples() {
    if (!mounted) return;
    setState(() {
      _templesFuture = _templeService.getTemples(
        sort: _sort == 'nearest' ? 'name_asc' : _sort,
        search: _searchController.text,
      );
    });
  }

  Future<void> _refresh() async {
    _templesFuture = _templeService.getTemples(
      sort: _sort == 'nearest' ? 'name_asc' : _sort,
      search: _searchController.text,
    );
    setState(() {});
    await _templesFuture;
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _position = null;
      _sort = 'name_asc';
      _locationError = null;
      _locationFailure = null;
    });
    try {
      final position = await NearbyTemples.locate();
      if (!mounted) return;
      setState(() {
        _position = position;
        _sort = 'nearest';
        _locationError = null;
        _locationFailure = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          if (error is NearbyLocationException) {
            _locationFailure = error.failure;
            _locationError = switch (error.failure) {
              NearbyLocationFailure.serviceDisabled =>
                'Vui lòng bật GPS để tìm chùa gần bạn.',
              NearbyLocationFailure.permissionDenied ||
              NearbyLocationFailure.permissionDeniedForever =>
                'Ứng dụng cần quyền vị trí để tìm chùa gần bạn.',
            };
          } else {
            _locationError = error is TimeoutException
                ? 'Chưa xác định được vị trí. Vui lòng thử lại.'
                : 'Không lấy được vị trí. Vui lòng thử lại.';
          }
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _openTemple(Temple temple) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => ChiTietChuaPage(temple: temple)),
    );
  }

  void _openNfcCheckIn() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const NfcScanPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: const Text('Chốn bình yên'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: 'Quét NFC để check-in tại chùa',
              child: TextButton.icon(
                onPressed: _openNfcCheckIn,
                icon: const Icon(Icons.nfc_rounded, size: 20),
                label: const Text('Check-In'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Tìm theo tên chùa hoặc địa chỉ',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Xóa tìm kiếm',
                                    onPressed: _searchController.clear,
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Tìm chùa gần bạn',
                        child: Semantics(
                          button: true,
                          label: 'Tìm chùa gần bạn bằng GPS',
                          child: IconButton.filledTonal(
                            key: const ValueKey('nearby-temples-location'),
                            onPressed: _locating ? null : _locate,
                            icon: _locating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_locating)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Đang xác định vị trí...',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  if (_locationError != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _locationError!,
                            style: const TextStyle(color: AppTheme.accent),
                          ),
                        ),
                        if (_locationFailure ==
                            NearbyLocationFailure.permissionDeniedForever)
                          TextButton(
                            onPressed: Geolocator.openAppSettings,
                            child: const Text('Mở cài đặt quyền'),
                          )
                        else if (_locationFailure ==
                            NearbyLocationFailure.serviceDisabled)
                          TextButton(
                            onPressed: Geolocator.openLocationSettings,
                            child: const Text('Bật GPS trong cài đặt'),
                          )
                        else
                          TextButton(
                            onPressed: _locating ? null : _locate,
                            child: Text(
                              _locationFailure ==
                                      NearbyLocationFailure.permissionDenied
                                  ? 'Cấp quyền vị trí'
                                  : 'Thử lại',
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.sort_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sắp xếp',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_sort),
                          initialValue: _sort,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            if (_position != null)
                              const DropdownMenuItem(
                                value: 'nearest',
                                child: Text('Gần bạn nhất'),
                              ),
                            DropdownMenuItem(
                              value: 'name_asc',
                              child: Text('Tên A–Z'),
                            ),
                            DropdownMenuItem(
                              value: 'name_desc',
                              child: Text('Tên Z–A'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            _sort = value;
                            _loadTemples();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Temple>>(
                future: _templesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }

                  final source = snapshot.data ?? const <Temple>[];
                  final temples = _sort == 'nearest' && _position != null
                      ? NearbyTemples.sorted(
                          source,
                          _position!.latitude,
                          _position!.longitude,
                        )
                      : source;
                  if (temples.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 110),
                          Icon(
                            Icons.temple_buddhist_outlined,
                            size: 54,
                            color: AppTheme.secondary.withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _searchController.text.trim().isEmpty
                                ? 'Chưa có dữ liệu chùa.'
                                : 'Không tìm thấy chùa phù hợp.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: temples.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _buildTempleCard(temples[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 14),
          const Text(
            'Không thể tải danh sách chùa',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: _loadTemples,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempleCard(Temple temple) {
    final meters = _position == null
        ? null
        : NearbyTemples.distance(
            temple,
            _position!.latitude,
            _position!.longitude,
          );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openTemple(temple),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  temple.thumbnail.trim().isEmpty
                      ? _templeImagePlaceholder()
                      : Image.network(
                          temple.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _templeImagePlaceholder(),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF9EF),
                        shape: BoxShape.circle,
                      ),
                      child: SaveItemButton(id: temple.id, temple: true),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temple.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_position != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        meters == null
                            ? 'Chưa có tọa độ'
                            : meters < 1000
                            ? 'Cách bạn khoảng ${meters.round()} m'
                            : 'Cách bạn khoảng ${(meters / 1000).toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: AppTheme.warmBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (temple.fullAddress.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppTheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            temple.fullAddress,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (temple.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      temple.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _templeImagePlaceholder() {
    return Container(
      color: AppTheme.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.temple_buddhist_outlined,
        size: 58,
        color: AppTheme.secondary,
      ),
    );
  }
}
