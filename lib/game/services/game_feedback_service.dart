import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum GameFeedbackEvent { bite, playerHit, consume, levelUp, unlock, defeat }

abstract interface class GameFeedbackService {
  Future<void> preload();

  void trigger(GameFeedbackEvent event);
}

class DeviceGameFeedbackService implements GameFeedbackService {
  DeviceGameFeedbackService({GameFeedbackThrottle? throttle})
    : _throttle = throttle ?? GameFeedbackThrottle();

  static const _audioByEvent = <GameFeedbackEvent, String>{
    GameFeedbackEvent.bite: 'bite_v001.wav',
    GameFeedbackEvent.playerHit: 'bite_v001.wav',
    GameFeedbackEvent.consume: 'consume_v001.wav',
    GameFeedbackEvent.levelUp: 'level_up_v001.wav',
    GameFeedbackEvent.unlock: 'level_up_v001.wav',
    GameFeedbackEvent.defeat: 'defeat_v001.wav',
  };

  final GameFeedbackThrottle _throttle;

  @override
  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll(
        _audioByEvent.values.toSet().toList(),
      );
    } on Object {
      // Audio is optional feedback; gameplay remains available if a platform
      // blocks decoding or autoplay.
    }
  }

  @override
  void trigger(GameFeedbackEvent event) {
    if (!_throttle.allow(event)) {
      return;
    }
    unawaited(_play(event));
  }

  Future<void> _play(GameFeedbackEvent event) async {
    try {
      await FlameAudio.play(_audioByEvent[event]!);
    } on Object {
      // Web autoplay and unsupported test runners may reject playback.
    }
    if (kIsWeb) {
      return;
    }
    try {
      await switch (event) {
        GameFeedbackEvent.bite ||
        GameFeedbackEvent.consume => HapticFeedback.lightImpact(),
        GameFeedbackEvent.playerHit => HapticFeedback.mediumImpact(),
        GameFeedbackEvent.levelUp ||
        GameFeedbackEvent.unlock ||
        GameFeedbackEvent.defeat => HapticFeedback.heavyImpact(),
      };
    } on Object {
      // Haptics are best-effort and not available on every device.
    }
  }
}

class GameFeedbackThrottle {
  GameFeedbackThrottle({Duration Function()? elapsed})
    : _elapsed = elapsed ?? _sharedElapsed;

  static final Stopwatch _sharedClock = Stopwatch()..start();
  static Duration _sharedElapsed() => _sharedClock.elapsed;

  static const _cooldownByChannel = <_FeedbackChannel, Duration>{
    _FeedbackChannel.impact: Duration(milliseconds: 140),
    _FeedbackChannel.reward: Duration(milliseconds: 80),
    _FeedbackChannel.major: Duration(milliseconds: 300),
  };

  final Duration Function() _elapsed;
  final Map<_FeedbackChannel, Duration> _lastTriggeredAt = {};

  bool allow(GameFeedbackEvent event) {
    final channel = switch (event) {
      GameFeedbackEvent.bite ||
      GameFeedbackEvent.playerHit => _FeedbackChannel.impact,
      GameFeedbackEvent.consume => _FeedbackChannel.reward,
      GameFeedbackEvent.levelUp ||
      GameFeedbackEvent.unlock ||
      GameFeedbackEvent.defeat => _FeedbackChannel.major,
    };
    final now = _elapsed();
    final previous = _lastTriggeredAt[channel];
    if (previous != null && now - previous < _cooldownByChannel[channel]!) {
      return false;
    }
    _lastTriggeredAt[channel] = now;
    return true;
  }
}

enum _FeedbackChannel { impact, reward, major }

class SilentGameFeedbackService implements GameFeedbackService {
  const SilentGameFeedbackService();

  @override
  Future<void> preload() async {}

  @override
  void trigger(GameFeedbackEvent event) {}
}
