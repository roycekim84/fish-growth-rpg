import 'dart:convert';

import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:flutter/services.dart';

class QuestRepository {
  QuestRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<QuestDefinition>> loadAll() async {
    final source = await _assetBundle.loadString('assets/data/quests.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => QuestDefinition.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
