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
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF7F0E3), Color(0xFFF0E6D5)],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.spa_outlined, color: AppTheme.warmBrown, size: 26),
        const SizedBox(height: 8),
        const Text(
          'Kinh Pháp Cú',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.warmBrown,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const LinearProgressIndicator()
        else if (_failed)
          const Text(
            'Không thể tải câu Phật ngôn. Vui lòng thử lại.',
            textAlign: TextAlign.center,
          )
        else if (_quote == null)
          const Text('Chưa có câu Phật ngôn.', textAlign: TextAlign.center)
        else ...[
          Text(
            _quote!.content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: AppTheme.text,
            ),
          ),
          if (_quote!.source.trim().isNotEmpty &&
              _quote!.source.trim() != 'Kinh Pháp Cú') ...[
            const SizedBox(height: 8),
            Text(
              _quote!.source,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: const StadiumBorder(),
            ),
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            label: Text(_failed ? 'Thử lại' : 'Câu khác'),
          ),
        ),
      ],
    ),
  );
}
