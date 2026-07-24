import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:fish_growth_rpg/ui/theme/pixel_ui.dart';
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
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              PixelHeader(
                title: 'EXPLORER BOOK',
                closeButtonKey: const ValueKey('collection-close-button'),
                onClose: () => game.closeModal(FishGame.collectionOverlayId),
              ),
              const SizedBox(height: 10),
              const TabBar(
                tabs: [
                  Tab(text: 'SPECIES'),
                  Tab(text: 'REGIONS'),
                  Tab(text: 'QUESTS'),
                ],
                labelColor: PixelPalette.cream,
                unselectedLabelColor: PixelPalette.muted,
                indicatorColor: PixelPalette.mint,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [
                    _SpeciesCollectionList(game: game),
                    _RegionCollectionList(game: game),
                    _QuestCollectionList(game: game),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestCollectionList extends StatelessWidget {
  const _QuestCollectionList({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.world.player.progressChanges,
      builder: (context, revision, child) {
        final system = game.world.questSystem;
        return ListView.separated(
          itemCount: game.quests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final quest = game.quests[index];
            final status = game.world.player.progress.questStatus(quest.id);
            final progress = system?.progressFor(quest) ?? 0;
            final completed = status == QuestStatus.completed;
            final active = status == QuestStatus.active;
            return PixelPanel(
              key: ValueKey('quest-card-${quest.id}'),
              accent: completed
                  ? PixelPalette.green
                  : active
                  ? PixelPalette.gold
                  : PixelPalette.muted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${completed
                        ? "✓"
                        : active
                        ? "◆"
                        : "?"} ${quest.title}',
                    style: const TextStyle(
                      color: PixelPalette.cream,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quest.description,
                    style: const TextStyle(
                      color: Color(0xFFB7C8D6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completed
                        ? 'COMPLETE — ${quest.rewardText}'
                        : active
                        ? 'PROGRESS  $progress / ${quest.targetCount}'
                        : 'ASK NURI TO BEGIN',
                    style: TextStyle(
                      color: completed
                          ? PixelPalette.green
                          : active
                          ? PixelPalette.mint
                          : PixelPalette.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SpeciesCollectionList extends StatelessWidget {
  const _SpeciesCollectionList({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.world.player.progressChanges,
      builder: (context, revision, child) {
        final progress = game.world.player.progress;
        return ListView.separated(
          itemCount: game.species.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final species = game.species[index];
            final count = progress.eatenCountBySpeciesId[species.id] ?? 0;
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
              speciesId: species.id,
              stats:
                  'HP ${species.maxHp.toInt()}  STR ${species.strength.toInt()}  '
                  'SPD ${species.speed.toStringAsFixed(1)}  SIZE ${species.size.toStringAsFixed(1)}',
            );
          },
        );
      },
    );
  }
}

class _RegionCollectionList extends StatelessWidget {
  const _RegionCollectionList({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.world.player.progressChanges,
      builder: (context, revision, child) {
        final progress = game.world.player.progress;
        return ListView.separated(
          itemCount: game.regions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final region = game.regions[index];
            final discovered = progress.discoveredRegionIds.contains(region.id);
            final unlocked = progress.isRegionUnlocked(region.id);
            final points = progress.discoveredPointIdsForRegion(region.id);
            return PixelPanel(
              accent: discovered
                  ? PixelPalette.mint
                  : unlocked
                  ? PixelPalette.gold
                  : PixelPalette.muted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unlocked ? region.displayName : '???',
                    style: const TextStyle(
                      color: PixelPalette.cream,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    discovered
                        ? 'DISCOVERY  ${points.length} / ${region.discoveryPoints.length}'
                        : unlocked
                        ? 'GATE OPEN — ENTER NEXT'
                        : 'GATE LOCKED',
                    style: const TextStyle(
                      color: PixelPalette.mint,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    unlocked ? region.description : '아직 발견하지 못한 지역입니다.',
                    style: const TextStyle(
                      color: Color(0xFFB7C8D6),
                      fontSize: 11,
                    ),
                  ),
                  if (discovered) ...[
                    const SizedBox(height: 8),
                    for (final point in region.discoveryPoints)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '${points.contains(point.id) ? "✓" : "?"} '
                          '${points.contains(point.id) ? point.displayName : "미발견 장소"}',
                          style: TextStyle(
                            color: points.contains(point.id)
                                ? PixelPalette.cream
                                : PixelPalette.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
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
    required this.speciesId,
    required this.stats,
  });

  final String name;
  final String description;
  final int count;
  final int goal;
  final bool unlocked;
  final bool discovered;
  final String speciesId;
  final String stats;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(10),
      accent: unlocked ? PixelPalette.green : const Color(0xFF315C72),
      shadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: discovered ? '$name 발견됨' : '$name 미발견',
            child: PixelPanel(
              padding: const EdgeInsets.all(2),
              accent: discovered ? PixelPalette.mint : PixelPalette.muted,
              background: const Color(0xFF07101D),
              shadow: false,
              child: Stack(
                children: [
                  PixelFishPortrait(
                    speciesId: speciesId,
                    unlocked: discovered,
                    width: 58,
                    height: 42,
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: ColoredBox(
                      color: unlocked ? PixelPalette.green : PixelPalette.ink,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          unlocked
                              ? '✓'
                              : discovered
                              ? '!'
                              : '?',
                          style: TextStyle(
                            color: unlocked
                                ? const Color(0xFF052C22)
                                : PixelPalette.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                    color: PixelPalette.cream,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked ? 'SPECIES CHANGE READY' : '${goal - count} LEFT',
                  style: TextStyle(
                    color: unlocked ? PixelPalette.green : PixelPalette.blue,
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
