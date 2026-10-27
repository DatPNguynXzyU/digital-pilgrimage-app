import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../config/app_theme.dart';
import '../../models/scripture.dart';
import '../../widgets/content_thumbnail.dart';

class ChiTietKinhSachPage extends StatefulWidget {
  final Scripture scripture;
  const ChiTietKinhSachPage({super.key, required this.scripture});
  @override
  State<ChiTietKinhSachPage> createState() => _ChiTietKinhSachPageState();
}

class _ChiTietKinhSachPageState extends State<ChiTietKinhSachPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _scroll = ScrollController();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  double _fontSize = 18;
  double _speed = 24;
  bool _playing = false;
  bool _controlsVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
  }

  void _pause() {
    if (!_playing) return;
    _ticker.stop();
    setState(() => _playing = false);
  }

  void _toggle() {
    if (_playing) {
      _pause();
      return;
    }
    if (!_scroll.hasClients || _scroll.position.maxScrollExtent <= 0) return;
    if (_scroll.offset >= _scroll.position.maxScrollExtent - 1) {
      _scroll.jumpTo(0);
    }
    _lastTick = Duration.zero;
    setState(() => _playing = true);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final seconds = ((elapsed - _lastTick).inMicroseconds / 1000000).clamp(
      0.0,
      0.1,
    );
    _lastTick = elapsed;
    if (!_scroll.hasClients) {
      _pause();
      return;
    }
    final end = _scroll.position.maxScrollExtent;
    final next = (_scroll.offset + _speed * seconds).clamp(0.0, end);
    _scroll.jumpTo(next);
    if (next >= end) _pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scripture = widget.scripture;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(scripture.type),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        bottom: _controlsVisible
            ? PreferredSize(
                preferredSize: const Size.fromHeight(122),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(top: BorderSide(color: AppTheme.border)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _playing ? 'Đang tự cuộn' : 'Tự cuộn khi đọc',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: scripture.content.trim().isEmpty
                                ? null
                                : _toggle,
                            icon: Icon(
                              _playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            label: Text(_playing ? 'Tạm dừng' : 'Bắt đầu'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Chậm'),
                          Expanded(
                            child: Slider(
                              value: _speed,
                              min: 8,
                              max: 64,
                              divisions: 7,
                              label: 'Mức ${((_speed - 8) / 8 + 1).round()}',
                              semanticFormatterCallback: (v) =>
                                  'Tốc độ mức ${((v - 8) / 8 + 1).round()}',
                              onChanged: (value) =>
                                  setState(() => _speed = value),
                            ),
                          ),
                          const Text('Nhanh'),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : null,
        actions: [
          IconButton(
            tooltip: _controlsVisible ? 'Ẩn điều khiển tự cuộn' : 'Tự cuộn',
            isSelected: _controlsVisible,
            onPressed: () =>
                setState(() => _controlsVisible = !_controlsVisible),
            icon: Icon(
              _playing
                  ? Icons.pause_circle_outline
                  : Icons.auto_stories_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Giảm cỡ chữ',
            onPressed: _fontSize <= 14
                ? null
                : () => setState(() => _fontSize -= 2),
            icon: const Icon(Icons.text_decrease_rounded),
          ),
          IconButton(
            tooltip: 'Tăng cỡ chữ',
            onPressed: _fontSize >= 26
                ? null
                : () => setState(() => _fontSize += 2),
            icon: const Icon(Icons.text_increase_rounded),
          ),
        ],
      ),
      body: NotificationListener<ScrollStartNotification>(
        onNotification: (notification) {
          if (notification.dragDetails != null) _pause();
          return false;
        },
        child: ListView(
          key: const ValueKey('scripture-reader'),
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF6EDDF), Color(0xFFEDE0C8)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 80,
                      height: 96,
                      child: ContentThumbnail(
                        url: scripture.imageUrl,
                        icon: Icons.menu_book_rounded,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scripture.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  if (scripture.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      scripture.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppTheme.warmBrown,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.spa_outlined,
                    color: AppTheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(height: 18),
                  SelectableText(
                    scripture.content.trim().isEmpty
                        ? 'Nội dung đang được cập nhật.'
                        : scripture.content,
                    onSelectionChanged: (_, _) => _pause(),
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.85,
                      letterSpacing: 0.15,
                      color: AppTheme.text,
                    ),
                  ),
                  if (scripture.source.trim().isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppTheme.border),
                    ),
                    Text(
                      'Nguồn: ${scripture.source}',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
