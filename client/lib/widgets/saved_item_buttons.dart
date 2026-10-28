import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../services/saved_items_store.dart';

class SaveItemButton extends StatefulWidget {
  final String id;
  final bool temple;
  final bool filled;

  const SaveItemButton({
    super.key,
    required this.id,
    required this.temple,
    this.filled = false,
  });

  @override
  State<SaveItemButton> createState() => _SaveItemButtonState();
}

class _SaveItemButtonState extends State<SaveItemButton> {
  final _store = SavedItemsStore();
  bool _saved = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    SavedItemsStore.changes.addListener(_refresh);
    _refresh();
  }

  @override
  void didUpdateWidget(covariant SaveItemButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.temple != widget.temple) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final items = widget.temple
        ? await _store.loadTemples()
        : await _store.loadEvents();
    if (mounted) setState(() => _saved = items.contains(widget.id));
  }

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final saved = widget.temple
          ? await _store.toggleTemple(widget.id)
          : await _store.toggleEvent(widget.id);
      if (!mounted) return;
      setState(() => _saved = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved ? 'Đã lưu vào mục yêu thích.' : 'Đã bỏ khỏi mục yêu thích.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể cập nhật mục đã lưu.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    SavedItemsStore.changes.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: _saved ? 'Bỏ lưu' : 'Lưu yêu thích',
    onPressed: _busy ? null : _toggle,
    icon: _busy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: _saved ? AppTheme.accent : AppTheme.primary,
          ),
  );
}
