import 'dart:async';

import 'package:flutter/material.dart';

import '../services/nfc_launch_service.dart';
import '../views/nfc/nfc_scan_page.dart';
import '../views/nfc/nfc_link_page.dart';

/// Defers the tag until the backend and biometric gates allow interaction.
class NfcLaunchGate extends StatefulWidget {
  const NfcLaunchGate({
    super.key,
    required this.navigatorKey,
    required this.child,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<NfcLaunchGate> createState() => _NfcLaunchGateState();
}

class _NfcLaunchGateState extends State<NfcLaunchGate>
    with WidgetsBindingObserver {
  final _service = NfcLaunchService();
  NfcLaunchTag? _pending;
  String? _lastEventId;
  bool _interactive = false;
  bool _draining = false;
  bool _routeOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service.addListener(_schedule);
    _service.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _interactive = TickerMode.valuesOf(context).enabled;
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _schedule();
  }

  bool get _canOpen {
    final state = WidgetsBinding.instance.lifecycleState;
    return mounted &&
        _interactive &&
        (state == null || state == AppLifecycleState.resumed);
  }

  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_drain()));
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _drain() async {
    if (!_canOpen || _draining || _routeOpen) return;
    _draining = true;
    try {
      _pending ??= await _service.takePendingTag();
      if (!_canOpen || _pending == null) return;
      if (NfcLaunchService.managementActive) {
        _pending = null;
        return;
      }
      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) return;
      final tag = _pending!;
      _pending = null;
      if (tag.eventId == _lastEventId) return;
      _lastEventId = tag.eventId;
      _routeOpen = true;
      try {
        await navigator.push<void>(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/nfc/check-in'),
            builder: (_) => tag.slug != null
                ? NfcLinkPage(slug: tag.slug!)
                : NfcScanPage(initialUid: tag.uid),
          ),
        );
      } finally {
        // A repeated tap while showing the result must not queue another visit.
        await _service.takePendingTag();
        _routeOpen = false;
      }
    } finally {
      _draining = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _service.removeListener(_schedule);
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
