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
}
