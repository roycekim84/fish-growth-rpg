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
    this.schemaVersion = currentSchemaVersion,
  }) : unlockedSpeciesIds = Set.unmodifiable(unlockedSpeciesIds),
       discoveredSpeciesIds = Set.unmodifiable(discoveredSpeciesIds),
       eatenCountBySpeciesId = Map.unmodifiable(eatenCountBySpeciesId);

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final int level;
  final int exp;
  final double fullness;
  final double hp;
  final String currentSpeciesId;
  final Set<String> unlockedSpeciesIds;
  final Set<String> discoveredSpeciesIds;
  final Map<String, int> eatenCountBySpeciesId;
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
      lastSaveTimeUtc: savedAt.toUtc(),
    );
  }

  factory PlayerSaveData.fromJson(Map<String, Object?> json) {
    final schemaVersion = _requiredInt(json, 'schemaVersion');
    if (schemaVersion != currentSchemaVersion) {
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
      schemaVersion: schemaVersion,
      level: level,
      exp: exp,
      fullness: fullness.clamp(0, PlayerProgress.maxFullness),
      hp: hp,
      currentSpeciesId: currentSpeciesId,
      unlockedSpeciesIds: unlocked,
      discoveredSpeciesIds: discovered,
      eatenCountBySpeciesId: eatenCounts,
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
