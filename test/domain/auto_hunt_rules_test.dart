import 'package:fish_growth_rpg/domain/rules/auto_hunt_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoHuntRules', () {
    test('selects only the nearest instantly edible candidate', () {
      final candidates = [
        const _Candidate(size: 0.6, distanceSquared: 400),
        const _Candidate(size: 0.6, distanceSquared: 100),
        const _Candidate(size: 0.6, distanceSquared: 10, alive: false),
        const _Candidate(size: 1.0, distanceSquared: 25),
      ];

      final selected = AutoHuntRules.nearestEdible<_Candidate>(
        candidates: candidates,
        playerSize: 0.8,
        isAlive: (candidate) => candidate.alive,
        npcSize: (candidate) => candidate.size,
        distanceSquared: (candidate) => candidate.distanceSquared,
      );

      expect(selected, same(candidates[1]));
    });

    test('detects a dangerous candidate only inside the safety radius', () {
      const danger = _Candidate(size: 1.3, distanceSquared: 10000);

      expect(
        AutoHuntRules.hasNearbyDanger<_Candidate>(
          candidates: const [danger],
          playerSize: 0.8,
          dangerDistanceSquared: 150 * 150,
          isAlive: (candidate) => candidate.alive,
          npcSize: (candidate) => candidate.size,
          distanceSquared: (candidate) => candidate.distanceSquared,
        ),
        isTrue,
      );
      expect(
        AutoHuntRules.hasNearbyDanger<_Candidate>(
          candidates: const [danger],
          playerSize: 0.8,
          dangerDistanceSquared: 90 * 90,
          isAlive: (candidate) => candidate.alive,
          npcSize: (candidate) => candidate.size,
          distanceSquared: (candidate) => candidate.distanceSquared,
        ),
        isFalse,
      );
    });
  });
}

class _Candidate {
  const _Candidate({
    required this.size,
    required this.distanceSquared,
    this.alive = true,
  });

  final double size;
  final double distanceSquared;
  final bool alive;
}
