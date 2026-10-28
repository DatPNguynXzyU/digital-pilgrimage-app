import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/services/mok_audio_service.dart';

class _TestAudioCache extends AudioCache {
  @override
  Future<String> loadPath(String fileName) async => '/test/$fileName';
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  const channel = MethodChannel('xyz.luan/audioplayers');
  const codec = StandardMethodCodec();
  final calls = <MethodCall>[];
  late AudioCache originalCache;

  setUp(() {
    calls.clear();
    originalCache = AudioCache.instance;
    AudioCache.instance = _TestAudioCache();
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      final args = call.arguments as Map;
      final id = args['playerId'] as String;
      if (call.method == 'create') {
        messenger.setMockMethodCallHandler(
          MethodChannel('xyz.luan/audioplayers/events/$id'),
          (_) async => null,
        );
      }
      if (call.method == 'setSourceUrl') {
        await messenger.handlePlatformMessage(
          'xyz.luan/audioplayers/events/$id',
          codec.encodeSuccessEnvelope({
            'event': 'audio.onPrepared',
            'value': true,
          }),
          (_) {},
        );
      }
      if (call.method == 'getDuration') return null;
      if (call.method == 'getCurrentPosition') return 0;
      return null;
    });
  });

  tearDown(() async {
    await MokAudioService.instance.stopAndDispose();
    await MokAudioService.bell.stopAndDispose();
    AudioCache.instance = originalCache;
    debugDefaultTargetPlatformOverride = null;
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test('Mok strikes preserve the bell ring on ${platform.name}', () async {
      debugDefaultTargetPlatformOverride = platform;
      await MokAudioService.bell.prepare();
      await MokAudioService.instance.prepare();
      expect(await MokAudioService.bell.playOnce(), isTrue);
      final bellId =
          (calls.lastWhere((c) => c.method == 'resume').arguments
              as Map)['playerId'];

      calls.clear();
      expect(await MokAudioService.instance.playOnce(), isTrue);
      expect(await MokAudioService.instance.playOnce(), isTrue);
      expect(
        calls.where(
          (c) =>
              ['stop', 'pause', 'release', 'dispose'].contains(c.method) &&
              (c.arguments as Map)['playerId'] == bellId,
        ),
        isEmpty,
      );

      // Recreate players to inspect the context passed to each native player.
      await MokAudioService.instance.stopAndDispose();
      await MokAudioService.bell.stopAndDispose();
      calls.clear();
      await MokAudioService.bell.prepare();
      await MokAudioService.instance.prepare();
      final contexts = calls.where((c) => c.method == 'setAudioContext');
      expect(contexts, hasLength(2));
      for (final call in contexts) {
        final context = call.arguments as Map;
        if (platform == TargetPlatform.android) {
          expect(context['audioFocus'], AndroidAudioFocus.none.value);
        } else {
          expect(context['options'], contains('mixWithOthers'));
        }
      }
    });
  }
}
