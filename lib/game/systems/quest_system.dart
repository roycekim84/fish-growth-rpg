import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:fish_growth_rpg/domain/models/region_definition.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class QuestSystem extends Component {
  QuestSystem({
    required this.player,
    required this.region,
    required List<QuestDefinition> quests,
    required this.npcPosition,
    required this.onQuestCompleted,
  }) : quests = List.unmodifiable(quests);

  final PlayerFishComponent player;
  final RegionDefinition region;
  final List<QuestDefinition> quests;
  final Vector2 npcPosition;
  final void Function(QuestDefinition quest, bool unlockedSpecies)
  onQuestCompleted;
  final ValueNotifier<bool> canTalk = ValueNotifier<bool>(false);

  static const double talkDistance = 130;
  double _progressTimer = 0;

  QuestDefinition? get nextInactiveQuest {
    for (final quest in quests) {
      final status = player.progress.questStatus(quest.id);
      if (status == QuestStatus.active) {
        return null;
      }
      if (status == QuestStatus.inactive) {
        return quest;
      }
    }
    return null;
  }

  bool startNextQuest() {
    final quest = nextInactiveQuest;
    if (quest == null || !player.progress.startQuest(quest.id)) {
      return false;
    }
    player.progressChanges.value++;
    return true;
  }

  int progressFor(QuestDefinition quest) {
    return switch (quest.objectiveType) {
      QuestObjectiveType.discoverPoints =>
        player.progress
            .discoveredPointIdsForRegion(quest.regionId ?? region.id)
            .length,
      QuestObjectiveType.consumeSpecies =>
        player.progress.eatenCountBySpeciesId[quest.speciesId] ?? 0,
    };
  }

  @override
  void update(double dt) {
    super.update(dt);
    canTalk.value = player.position.distanceTo(npcPosition) <= talkDistance;
    _progressTimer += dt;
    if (_progressTimer < 0.2) {
      return;
    }
    _progressTimer = 0;
    for (final quest in quests) {
      if (player.progress.questStatus(quest.id) != QuestStatus.active ||
          progressFor(quest) < quest.targetCount) {
        continue;
      }
      if (!player.progress.completeQuest(quest.id)) {
        continue;
      }
      final rewardSpecies = quest.rewardSpeciesId;
      final unlockedSpecies =
          rewardSpecies != null &&
          player.progress.unlockSpeciesFromQuest(rewardSpecies);
      player.progressChanges.value++;
      onQuestCompleted(quest, unlockedSpecies);
    }
  }

  @override
  void onRemove() {
    canTalk.dispose();
    super.onRemove();
  }
}
