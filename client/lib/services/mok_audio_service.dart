import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Preloaded, independent sound pools shared by scripture readers.
class MokAudioService {
  MokAudioService._(this._asset, {required Duration duration})
    : _soundDuration = duration;

  static final MokAudioService instance = MokAudioService._(
    'audio/mokugyo.wav',
    duration: const Duration(seconds: 4),
  );
  static final MokAudioService bell = MokAudioService._(
    'audio/temple_bell.wav',
    duration: const Duration(seconds: 6),
  );

  final String _asset;

  AudioPool? _pool;
  Future<AudioPool>? _poolFuture;
  StopFunction? _activeStop;
  Timer? _retirementTimer;
  Duration _soundDuration;
  bool _isPlaying = false;
  int _generation = 0;
  Future<void> _disposing = Future<void>.value();

  bool get isPlaying => _isPlaying;

  /// Load the local sound before the first tap. This does not play anything.
  Future<void> prepare() async {
    try {
      await _disposing;
      final pool = await _getPool();
      _soundDuration = await pool.getDuration() ?? _soundDuration;
    } catch (_) {
      // Keep the tap path responsible for reporting playback errors to users.
    }
  }

  Future<bool> playOnce() async {
    await _disposing;
    if (_isPlaying) return false;
    _isPlaying = true;
    final generation = ++_generation;

    try {
      // Restart only this instrument; never stop the other instrument's ring.
      _retirementTimer?.cancel();
      _retirementTimer = null;
      final previousStop = _activeStop;
      _activeStop = null;
      if (previousStop != null) await previousStop();

      final pool = await _getPool();
      if (_generation != generation) return false;
      final stop = await pool.start(volume: 0.75);
      if (_generation != generation) {
        await stop();
        return false;
      }
      _activeStop = stop;
      _retirementTimer = Timer(_soundDuration, () {
        unawaited(_retire(stop, generation));
      });
      return true;
    } catch (_) {
      return false;
    } finally {
      if (_generation == generation) _isPlaying = false;
    }
  }

  Future<void> _retire(StopFunction stop, int generation) async {
    if (_generation != generation || !identical(_activeStop, stop)) return;
    _activeStop = null;
    _retirementTimer = null;
    try {
      await stop();
    } catch (_) {}
  }

  Future<AudioPool> _getPool() async {
    final existing = _pool;
    if (existing != null) return existing;

    final generation = _generation;
    final pending = _poolFuture ??= AudioPool.create(
      source: AssetSource(_asset),
      minPlayers: 1,
      maxPlayers: 1,
      playerMode: PlayerMode.lowLatency,
      // Neither instrument should steal audio focus from the other.
      audioContext: AudioContext(
        android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    try {
      final pool = await pending;
      if (_generation != generation) {
        throw StateError('Mok audio pool was closed.');
      }
      _pool = pool;
      return pool;
    } catch (_) {
      if (identical(_poolFuture, pending)) _poolFuture = null;
      rethrow;
    }
  }

  /// Stop and release native resources when the reader route is removed.
  Future<void> stopAndDispose() {
    final pool = _pool;
    final poolFuture = _poolFuture;
    final activeStop = _activeStop;
    _retirementTimer?.cancel();
    _retirementTimer = null;
    _pool = null;
    _poolFuture = null;
    _activeStop = null;
    ++_generation;
    _isPlaying = false;
    final disposal = _dispose(pool, poolFuture, activeStop);
    _disposing = disposal;
    return disposal;
  }

  Future<void> _dispose(
    AudioPool? pool,
    Future<AudioPool>? poolFuture,
    StopFunction? activeStop,
  ) async {
    if (activeStop != null) {
      try {
        await activeStop();
      } catch (_) {}
    }
    AudioPool? resolvedPool = pool;
    if (resolvedPool == null && poolFuture != null) {
      try {
        resolvedPool = await poolFuture;
      } catch (_) {}
    }
    try {
      await resolvedPool?.dispose();
    } catch (_) {}
  }
}
