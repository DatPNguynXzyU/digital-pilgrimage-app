import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/quote.dart';
import '../../services/quote_service.dart';

class HomeDhammapadaCard extends StatefulWidget {
  const HomeDhammapadaCard({super.key, this.loadQuote});
  final Future<Quote?> Function(String? exclude)? loadQuote;

  @override
  State<HomeDhammapadaCard> createState() => _HomeDhammapadaCardState();
}

class _HomeDhammapadaCardState extends State<HomeDhammapadaCard> {
  Quote? _quote;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final quote =
          await (widget.loadQuote?.call(_quote?.code) ??
              QuoteService().random(exclude: _quote?.code));
      if (mounted) setState(() => _quote = quote);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('dhammapada-card'),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFF0E6D5),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kinh Pháp Cú',
          style: TextStyle(
            color: AppTheme.warmBrown,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (_loading)
          const LinearProgressIndicator()
        else if (_failed)
          const Text('Không thể tải câu Phật ngôn. Vui lòng thử lại.')
        else if (_quote == null)
          const Text('Chưa có câu Phật ngôn.')
        else ...[
          Text(
            _quote!.content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            _quote!.source,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            label: Text(_failed ? 'Thử lại' : 'Câu khác'),
          ),
        ),
      ],
    ),
  );
}
