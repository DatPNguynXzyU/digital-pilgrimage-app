import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_launch_service.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_service.dart';
import 'package:hanh_trinh_an_nhien/widgets/nfc_launch_gate.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  Map<String, String>? pending;
  late GlobalKey<NavigatorState> navigator;
  late ValueNotifier<bool> unlocked;

  Future<void> notifyTap() async {
    await messenger.handlePlatformMessage(
      NfcLaunchService.channel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('tagAvailable'),
      ),
      (_) {},
    );
  }

  Widget app() => MaterialApp(
    navigatorKey: navigator,
    builder: (_, child) => ValueListenableBuilder<bool>(
      valueListenable: unlocked,
      builder: (_, enabled, _) => TickerMode(
        enabled: enabled,
        child: NfcLaunchGate(navigatorKey: navigator, child: child!),
      ),
    ),
    home: const Scaffold(body: Text('Trang chủ thử nghiệm')),
  );

  setUp(() {
    pending = {'uid': '04AB0102', 'eventId': 'tap-1'};
    navigator = GlobalKey<NavigatorState>();
    unlocked = ValueNotifier(true);
    SharedPreferences.setMockInitialValues({'auth_token': 'session'});
    messenger.setMockMethodCallHandler(NfcLaunchService.channel, (call) async {
      expect(call.method, 'takePendingTag');
      final tag = pending;
      pending = null;
      return tag;
    });
  });

  tearDown(() => unlocked.dispose());
  testWidgets('management taps do not open check-in or award a stamp', (
    tester,
  ) async {
    NfcLaunchService.managementActive = true;
    try {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Trang chủ thử nghiệm'), findsOneWidget);
      expect(find.text('Check-in NFC'), findsNothing);
      expect(pending, isNull);
    } finally {
      NfcLaunchService.managementActive = false;
    }
  });

  http.Response success() => http.Response(
    jsonEncode({
      'success': true,
      'message': 'Đã nhận tem từ lần chạm thẻ',
      'data': {
        'temple': {
          '_id': 'temple-1',
          'name': 'Chùa thử nghiệm',
          'slug': 'chua-thu',
        },
        'visit': {'visitCount': 1},
        'stamp': {'isNew': true},
      },
    }),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  test(
    'native payload accepts only physical hexadecimal UIDs and event IDs',
    () {
      expect(
        NfcLaunchTag.fromNative({'uid': '04ab0102', 'eventId': 'tap'})!.uid,
        '04AB0102',
      );
      expect(
        NfcLaunchTag.fromNative({
          'uid': 'https://example.com',
          'eventId': 'tap',
        }),
        isNull,
      );
      expect(NfcLaunchTag.fromNative({'uid': '04AB0102'}), isNull);
      expect(NfcLaunchTag.fromNative({'uid': 'ABC', 'eventId': 'tap'}), isNull);
    },
  );

  testWidgets(
    'cold tap checks in once; warm tap opens the result without the temple tab',
    (tester) async {
      var posts = 0;
      final revision = NfcService.checkIns.value;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(app());
          await tester.pumpAndSettle();
          expect(find.text('Tem mới!'), findsOneWidget);
          expect(posts, 1);
          expect(NfcService.checkIns.value, revision + 1);
          await notifyTap();
          await tester.pumpAndSettle();
          expect(posts, 1);
          navigator.currentState!.pop();
          await tester.pumpAndSettle();
          pending = {'uid': '04AB0102', 'eventId': 'tap-1'};
          await notifyTap();
          await tester.pumpAndSettle();
          expect(posts, 1);
          pending = {'uid': '04AB0103', 'eventId': 'tap-2'};
          await notifyTap();
          await tester.pumpAndSettle();
          expect(posts, 2);
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/nfc/scan');
          expect(request.headers['Authorization'], 'Bearer session');
          expect(jsonDecode(request.body), {
            'uid': posts == 0 ? '04AB0102' : '04AB0103',
          });
          posts++;
          return success();
        }),
      );
    },
  );

  testWidgets('tap waits behind biometric or backend gates', (tester) async {
    unlocked.value = false;
    var posts = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(posts, 0);
        expect(pending, isNotNull);
        unlocked.value = true;
        await tester.pumpAndSettle();
        expect(posts, 1);
        await tester.pumpWidget(const SizedBox());
      },
      () => MockClient((_) async {
        posts++;
        return success();
      }),
    );
  });

  testWidgets('logged-out tap is retained and checked in after login returns', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var posts = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(find.text('Yêu cầu đăng nhập'), findsOneWidget);
        expect(posts, 0);
        await tester.tap(find.text('Đăng nhập ngay'));
        await tester.pumpAndSettle();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'session');
        navigator.currentState!.pop();
        await tester.pumpAndSettle();
        expect(posts, 1);
        expect(find.text('Tem mới!'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
      () => MockClient((_) async {
        posts++;
        return success();
      }),
    );
  });

  testWidgets('unregistered tag shows backend error and awards no stamp', (
    tester,
  ) async {
    final revision = NfcService.checkIns.value;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(find.text('Thẻ không được đăng ký'), findsOneWidget);
        expect(find.text('Tem mới!'), findsNothing);
        expect(NfcService.checkIns.value, revision);
        await tester.pumpWidget(const SizedBox());
      },
      () => MockClient(
        (_) async => http.Response(
          jsonEncode({'success': false, 'message': 'Thẻ không được đăng ký'}),
          404,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
  });
}
