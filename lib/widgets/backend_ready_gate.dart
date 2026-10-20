import 'package:flutter/material.dart';

import '../services/backend_readiness.dart';

class BackendReadyGate extends StatefulWidget {
  const BackendReadyGate({super.key, required this.child});
  final Widget child;

  @override
  State<BackendReadyGate> createState() => _BackendReadyGateState();
}

class _BackendReadyGateState extends State<BackendReadyGate>
    with WidgetsBindingObserver {
  bool _ready = false;
  bool _checking = false;
  bool _opened = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _ready = false;
      _error = null;
    });
    try {
      await BackendReadiness.waitUntilReady();
      if (mounted) {
        setState(() {
          _ready = true;
          _opened = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Chưa kết nối được máy chủ. Kiểm tra mạng rồi thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (_opened) widget.child,
      if (!_ready)
        Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_checking) const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    _error ?? 'Đang kết nối máy chủ…\nLần mở đầu có thể mất khoảng một phút.',
                    textAlign: TextAlign.center,
                  ),
                  if (!_checking)
                    TextButton(onPressed: _check, child: const Text('Thử lại')),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
