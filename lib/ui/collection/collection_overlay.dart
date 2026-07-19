import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:flutter/material.dart';

class CollectionOverlay extends StatelessWidget {
  const CollectionOverlay({required this.game, super.key});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xF2071A2D),
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Column(
          children: [
            _Header(
              title: 'FISH COLLECTION',
              onClose: () => game.closeModal(FishGame.collectionOverlayId),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: game.world.player.progressChanges,
                builder: (context, revision, child) {
                  final progress = game.world.player.progress;
                  return ListView.separated(
                    itemCount: game.species.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final species = game.species[index];
                      final count =
                          progress.eatenCountBySpeciesId[species.id] ?? 0;
                      final unlocked = progress.isSpeciesUnlocked(species.id);
                      final discovered = progress.discoveredSpeciesIds.contains(
                        species.id,
                      );
                      return _CollectionCard(
                        name: species.displayName,
                        description: species.description,
                        count: count,
                        goal: species.unlockEatCount,
                        unlocked: unlocked,
                        discovered: discovered,
                        color: PlayerFishComponent.colorForSpecies(species.id),
                        stats:
                            'HP ${species.maxHp.toInt()}  STR ${species.strength.toInt()}  '
                            'SPD ${species.speed.toStringAsFixed(1)}  SIZE ${species.size.toStringAsFixed(1)}',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3A5A),
        border: Border.all(color: const Color(0xFF32D6C4), width: 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFB8FFF1),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('collection-close-button'),
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Color(0xFFFFF0B8)),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.name,
    required this.description,
    required this.count,
    required this.goal,
    required this.unlocked,
    required this.discovered,
    required this.color,
    required this.stats,
  });

  final String name;
  final String description;
  final int count;
  final int goal;
  final bool unlocked;
  final bool discovered;
  final Color color;
  final String stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xEE0A2B43),
        border: Border.all(
          color: unlocked ? const Color(0xFF5CFFB1) : const Color(0xFF315C72),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 40,
            decoration: BoxDecoration(
              color: discovered ? color : const Color(0xFF152A38),
              border: Border.all(color: const Color(0xFFB8FFF1), width: 2),
            ),
            child: Icon(
              unlocked ? Icons.check : Icons.lock,
              color: unlocked
                  ? const Color(0xFF052C22)
                  : const Color(0xFF78909C),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name  $count / $goal',
                  style: const TextStyle(
                    color: Color(0xFFFFF0B8),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked ? 'SPECIES CHANGE READY' : '${goal - count} LEFT',
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xFF5CFFB1)
                        : const Color(0xFF61AFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(stats, style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFB7C8D6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
