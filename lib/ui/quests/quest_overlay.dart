import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:fish_growth_rpg/ui/theme/pixel_ui.dart';
import 'package:flutter/material.dart';

class QuestOverlay extends StatelessWidget {
  const QuestOverlay({required this.game, super.key});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xF2071A2D),
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Column(
          children: [
            PixelHeader(
              title: 'NURI THE GUIDE',
              closeButtonKey: const ValueKey('quest-close-button'),
              onClose: () => game.closeModal(FishGame.questOverlayId),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: game.world.player.progressChanges,
                builder: (context, revision, child) {
                  final system = game.world.questSystem;
                  if (system == null) {
                    return const SizedBox.shrink();
                  }
                  return ListView.separated(
                    itemCount: system.quests.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const PixelPanel(
                          child: Text(
                            '◆ 조개 안내자 누리\n얕은 바다의 흔적을 찾아 다음 해류의 길을 열어 보자.',
                            style: TextStyle(
                              color: PixelPalette.mint,
                              fontSize: 12,
                              height: 1.45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      }
                      final quest = system.quests[index - 1];
                      final status = game.world.player.progress.questStatus(
                        quest.id,
                      );
                      return _QuestCard(
                        quest: quest,
                        status: status,
                        progress: system.progressFor(quest),
                        onStart:
                            status == QuestStatus.inactive &&
                                system.nextInactiveQuest?.id == quest.id
                            ? () => game.startNextQuest()
                            : null,
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

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.status,
    required this.progress,
    required this.onStart,
  });

  final QuestDefinition quest;
  final QuestStatus status;
  final int progress;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final done = status == QuestStatus.completed;
    final active = status == QuestStatus.active;
    return PixelPanel(
      accent: done ? PixelPalette.green : PixelPalette.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${done
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
            active || done ? quest.description : quest.giverGreeting,
            style: const TextStyle(
              color: Color(0xFFB7C8D6),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          if (active || done)
            PixelProgressBar(
              value: progress / quest.targetCount,
              valueText: '$progress / ${quest.targetCount}',
              color: done ? PixelPalette.green : PixelPalette.blue,
            ),
          const SizedBox(height: 8),
          Text(
            done
                ? 'REWARD  ${quest.rewardText}'
                : 'REWARD  ${quest.rewardText}',
            style: TextStyle(
              color: done ? PixelPalette.green : PixelPalette.gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (onStart != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: PixelButton(
                key: ValueKey('start-quest-${quest.id}'),
                label: 'ACCEPT',
                width: 82,
                onPressed: onStart,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
