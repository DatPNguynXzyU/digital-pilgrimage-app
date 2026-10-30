import 'package:flutter/material.dart';

import '../../models/temple.dart';
import '../../services/temple_service.dart';
import '../temples/chi_tiet_chua.dart';
import 'nfc_scan_page.dart';

class NfcLinkPage extends StatefulWidget {
  const NfcLinkPage({super.key, required this.slug});
  final String slug;
  @override
  State<NfcLinkPage> createState() => _NfcLinkPageState();
}

class _NfcLinkPageState extends State<NfcLinkPage> {
  late Future<Temple> _temple;
  @override
  void initState() {
    super.initState();
    _temple = TempleService().getTempleBySlug(widget.slug);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Temple>(
    future: _temple,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Scaffold(
          appBar: AppBar(title: const Text('Check-in chùa')),
          body: Center(
            child: snapshot.hasError
                ? TextButton(
                    onPressed: () => setState(() {
                      _temple = TempleService().getTempleBySlug(widget.slug);
                    }),
                    child: const Text('Chưa tải được chùa. Nhấn để thử lại'),
                  )
                : const CircularProgressIndicator(),
          ),
        );
      }
      return Scaffold(
        body: ChiTietChuaPage(temple: snapshot.data!),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              icon: const Icon(Icons.nfc),
              label: const Text('Chạm thẻ để check-in tại chùa này'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NfcScanPage(expectedSlug: widget.slug),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
