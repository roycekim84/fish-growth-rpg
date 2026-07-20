import 'dart:convert';

import 'package:fish_growth_rpg/domain/models/region_definition.dart';
import 'package:flutter/services.dart';

class RegionRepository {
  RegionRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<RegionDefinition>> loadAll() async {
    final source = await _assetBundle.loadString('assets/data/regions.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => RegionDefinition.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
