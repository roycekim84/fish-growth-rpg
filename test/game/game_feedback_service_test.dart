import 'package:fish_growth_rpg/game/services/game_feedback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'silent feedback service is safe for deterministic game tests',
    () async {
      const service = SilentGameFeedbackService();

      await service.preload();
      for (final event in GameFeedbackEvent.values) {
        service.trigger(event);
      }
    },
  );

  test('throttles overlapping feedback per sensory channel', () {
    var elapsed = Duration.zero;
    final throttle = GameFeedbackThrottle(elapsed: () => elapsed);

    expect(throttle.allow(GameFeedbackEvent.bite), isTrue);
    expect(throttle.allow(GameFeedbackEvent.playerHit), isFalse);
    expect(throttle.allow(GameFeedbackEvent.consume), isTrue);
    expect(throttle.allow(GameFeedbackEvent.levelUp), isTrue);
    expect(throttle.allow(GameFeedbackEvent.unlock), isFalse);

    elapsed = const Duration(milliseconds: 140);
    expect(throttle.allow(GameFeedbackEvent.playerHit), isTrue);
    expect(throttle.allow(GameFeedbackEvent.consume), isTrue);
    expect(throttle.allow(GameFeedbackEvent.defeat), isFalse);

    elapsed = const Duration(milliseconds: 300);
    expect(throttle.allow(GameFeedbackEvent.defeat), isTrue);
  });
}
