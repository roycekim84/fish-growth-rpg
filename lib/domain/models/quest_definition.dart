enum QuestObjectiveType { discoverPoints, consumeSpecies }

enum QuestStatus { inactive, active, completed }

class QuestDefinition {
  const QuestDefinition({
    required this.id,
    required this.title,
    required this.giverName,
    required this.giverGreeting,
    required this.description,
    required this.objectiveType,
    required this.targetCount,
    required this.rewardText,
    this.regionId,
    this.speciesId,
    this.rewardSpeciesId,
  });

  factory QuestDefinition.fromJson(Map<String, dynamic> json) {
    return QuestDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      giverName: json['giverName'] as String,
      giverGreeting: json['giverGreeting'] as String,
      description: json['description'] as String,
      objectiveType: QuestObjectiveType.values.byName(
        json['objectiveType'] as String,
      ),
      targetCount: json['targetCount'] as int,
      regionId: json['regionId'] as String?,
      speciesId: json['speciesId'] as String?,
      rewardSpeciesId: json['rewardSpeciesId'] as String?,
      rewardText: json['rewardText'] as String,
    );
  }

  final String id;
  final String title;
  final String giverName;
  final String giverGreeting;
  final String description;
  final QuestObjectiveType objectiveType;
  final int targetCount;
  final String? regionId;
  final String? speciesId;
  final String? rewardSpeciesId;
  final String rewardText;
}
