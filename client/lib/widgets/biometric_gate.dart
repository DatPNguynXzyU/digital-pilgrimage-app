import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/biometric_lock.dart';
import '../services/nfc_platform_support.dart';

class BiometricGate extends StatefulWidget {
  const BiometricGate({
    super.key,
    required this.child,
    this.authenticate = BiometricLock.authenticate,
  });
  final Widget child;
  final Future<bool> Function() authenticate;

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate>
    with WidgetsBindingObserver {
  bool _ready = false;
  bool _enabled = false;
  bool _locked = true;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthService.sessionChanges.addListener(_refresh);
    BiometricLock.changes.addListener(_refresh);
    _refresh();
  }

  Future<void> _refresh() async {
    final enabled =
        await BiometricLock.enabled() && await AuthService().isLoggedIn();
    if (!mounted) return;
    setState(() {
      // Enabling requires a successful biometric challenge in Settings.
      if (!enabled || (_ready && !_enabled && enabled)) _locked = false;
      _enabled = enabled;
      _ready = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final background =
        state == AppLifecycleState.paused || state == AppLifecycleState.hidden;
    if ((background ||
            (state == AppLifecycleState.inactive &&
                !NfcPlatformSupport.hasIosSheet)) &&
        _enabled &&
        !BiometricLock.authenticating) {
      setState(() => _locked = true);
    }
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final verified = await widget.authenticate();
      if (mounted) {
        setState(() {
          _locked = !verified;
          if (!verified) _message = 'Chưa xác thực. Bạn có thể thử lại.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'Không thể dùng sinh trắc học. Hãy thử lại hoặc đăng xuất để dùng mật khẩu.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthService.sessionChanges.removeListener(_refresh);
    BiometricLock.changes.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocked = !_ready || (_enabled && _locked);
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(
          offstage: blocked,
          child: TickerMode(enabled: !blocked, child: widget.child),
        ),
        if (blocked)
          Positioned.fill(
            child: Material(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: !_ready
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fingerprint, size: 64),
                              const SizedBox(height: 16),
                              const Text('Mở khóa ứng dụng'),
                              if (_message != null)
                                Text(_message!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _busy ? null : _unlock,
                                child: Text(
                                  _busy ? 'Đang xác thực…' : 'Xác thực vân tay',
                                ),
                              ),
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () async {
                                        await AuthService().logout();
                                      },
                                child: const Text('Đăng xuất để dùng mật khẩu'),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
