import 'package:fish_growth_rpg/domain/models/player_progress.dart';

class PlayerSaveData {
  PlayerSaveData({
    required this.level,
    required this.exp,
    required this.fullness,
    required this.hp,
    required this.currentSpeciesId,
    required Set<String> unlockedSpeciesIds,
    required Set<String> discoveredSpeciesIds,
    required Map<String, int> eatenCountBySpeciesId,
    required this.lastSaveTimeUtc,
    Set<String>? discoveredRegionIds,
    Map<String, Set<String>>? discoveredPointIdsByRegionId,
    this.schemaVersion = currentSchemaVersion,
  }) : unlockedSpeciesIds = Set.unmodifiable(unlockedSpeciesIds),
       discoveredSpeciesIds = Set.unmodifiable(discoveredSpeciesIds),
       eatenCountBySpeciesId = Map.unmodifiable(eatenCountBySpeciesId),
       discoveredRegionIds = Set.unmodifiable(discoveredRegionIds ?? const {}),
       discoveredPointIdsByRegionId = Map.unmodifiable({
         for (final entry
             in discoveredPointIdsByRegionId?.entries ??
                 const <MapEntry<String, Set<String>>>[])
           entry.key: Set.unmodifiable(entry.value),
       });

  static const int currentSchemaVersion = 2;

  final int schemaVersion;
  final int level;
  final int exp;
  final double fullness;
  final double hp;
  final String currentSpeciesId;
  final Set<String> unlockedSpeciesIds;
  final Set<String> discoveredSpeciesIds;
  final Map<String, int> eatenCountBySpeciesId;
  final Set<String> discoveredRegionIds;
  final Map<String, Set<String>> discoveredPointIdsByRegionId;
  final DateTime lastSaveTimeUtc;

  factory PlayerSaveData.capture({
    required PlayerProgress progress,
    required double hp,
    required DateTime savedAt,
  }) {
    return PlayerSaveData(
      level: progress.level,
      exp: progress.exp,
      fullness: progress.fullness,
      hp: hp,
      currentSpeciesId: progress.currentSpeciesId,
      unlockedSpeciesIds: progress.unlockedSpeciesIds,
      discoveredSpeciesIds: progress.discoveredSpeciesIds,
      eatenCountBySpeciesId: progress.eatenCountBySpeciesId,
      discoveredRegionIds: progress.discoveredRegionIds,
      discoveredPointIdsByRegionId: progress.discoveredPointIdsByRegionId,
      lastSaveTimeUtc: savedAt.toUtc(),
    );
  }

  factory PlayerSaveData.fromJson(Map<String, Object?> json) {
    final schemaVersion = _requiredInt(json, 'schemaVersion');
    if (schemaVersion < 1 || schemaVersion > currentSchemaVersion) {
      throw UnsupportedSaveVersion(schemaVersion);
    }

    final level = _requiredInt(json, 'level');
    final exp = _requiredInt(json, 'exp');
    final fullness = _requiredDouble(json, 'fullness');
    final hp = _requiredDouble(json, 'hp');
    final currentSpeciesId = _requiredString(json, 'currentSpeciesId');
    final unlocked = _requiredStringSet(json, 'unlockedSpeciesIds');
    final discovered = _requiredStringSet(json, 'discoveredSpeciesIds');
    final eatenCounts = _requiredCountMap(json, 'eatenCountBySpeciesId');
    final discoveredRegions = _optionalStringSet(json, 'discoveredRegionIds');
    final discoveredPoints = _optionalPointMap(
      json,
      'discoveredPointIdsByRegionId',
    );
    final savedAtText = _requiredString(json, 'lastSaveTimeUtc');
    final savedAt = DateTime.tryParse(savedAtText);

    if (level < 1 ||
        exp < 0 ||
        exp >= 20 + level * 10 ||
        fullness < 0 ||
        hp < 0 ||
        savedAt == null) {
      throw const FormatException('Save data contains invalid values.');
    }

    return PlayerSaveData(
      schemaVersion: currentSchemaVersion,
      level: level,
      exp: exp,
      fullness: fullness.clamp(0, PlayerProgress.maxFullness),
      hp: hp,
      currentSpeciesId: currentSpeciesId,
      unlockedSpeciesIds: unlocked,
      discoveredSpeciesIds: discovered,
      eatenCountBySpeciesId: eatenCounts,
      discoveredRegionIds: discoveredRegions,
      discoveredPointIdsByRegionId: discoveredPoints,
      lastSaveTimeUtc: savedAt.toUtc(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'level': level,
      'exp': exp,
      'fullness': fullness,
      'hp': hp,
      'currentSpeciesId': currentSpeciesId,
      'unlockedSpeciesIds': unlockedSpeciesIds.toList()..sort(),
      'discoveredSpeciesIds': discoveredSpeciesIds.toList()..sort(),
      'discoveredRegionIds': discoveredRegionIds.toList()..sort(),
      'discoveredPointIdsByRegionId': Map.fromEntries(
        discoveredPointIdsByRegionId.entries
            .map((entry) => MapEntry(entry.key, entry.value.toList()..sort()))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      ),
      'eatenCountBySpeciesId': Map.fromEntries(
        eatenCountBySpeciesId.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      ),
      'lastSaveTimeUtc': lastSaveTimeUtc.toUtc().toIso8601String(),
    };
  }

  static int _requiredInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    throw FormatException('Missing or invalid $key.');
  }

  static double _requiredDouble(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is num && value.isFinite) {
      return value.toDouble();
    }
    throw FormatException('Missing or invalid $key.');
  }

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('Missing or invalid $key.');
  }

  static Set<String> _requiredStringSet(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Missing or invalid $key.');
    }
    return value.cast<String>().where((item) => item.isNotEmpty).toSet();
  }

  static Set<String> _optionalStringSet(Map<String, Object?> json, String key) {
    if (!json.containsKey(key)) {
      return <String>{};
    }
    return _requiredStringSet(json, key);
  }

  static Map<String, Set<String>> _optionalPointMap(
    Map<String, Object?> json,
    String key,
  ) {
    if (!json.containsKey(key)) {
      return <String, Set<String>>{};
    }
    final value = json[key];
    if (value is! Map) {
      throw FormatException('Missing or invalid $key.');
    }
    final result = <String, Set<String>>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.key.isEmpty || entry.value is! List) {
        throw FormatException('Missing or invalid $key.');
      }
      final points = entry.value;
      if (points.any((item) => item is! String || item.isEmpty)) {
        throw FormatException('Missing or invalid $key.');
      }
      result[entry.key] = points.cast<String>().toSet();
    }
    return result;
  }

  static Map<String, int> _requiredCountMap(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! Map) {
      throw FormatException('Missing or invalid $key.');
    }
    final result = <String, int>{};
    for (final entry in value.entries) {
      if (entry.key is! String ||
          (entry.key as String).isEmpty ||
          entry.value is! int ||
          (entry.value as int) < 0) {
        throw FormatException('Missing or invalid $key.');
      }
      result[entry.key as String] = entry.value as int;
    }
    return result;
  }
}

class UnsupportedSaveVersion implements Exception {
  const UnsupportedSaveVersion(this.version);

  final int version;

  @override
  String toString() => 'Unsupported save schema version: $version';
}
