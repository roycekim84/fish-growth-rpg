import 'dart:convert';

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:flutter/services.dart';

class SpeciesRepository {
  SpeciesRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<FishSpecies>> loadAll() async {
    final source = await _assetBundle.loadString(
      'assets/data/fish_species.json',
    );
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => FishSpecies.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
