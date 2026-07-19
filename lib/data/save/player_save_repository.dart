import 'dart:convert';

import 'package:fish_growth_rpg/domain/models/player_save_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PlayerSaveRepository {
  Future<SaveLoadResult> load();

  Future<void> save(PlayerSaveData data);
}

enum SaveLoadState { empty, loaded, recoveredCorrupt, unsupportedVersion }

class SaveLoadResult {
  const SaveLoadResult({required this.state, this.data});

  final SaveLoadState state;
  final PlayerSaveData? data;
}

abstract interface class StringPreferencesStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}

class SharedPreferencesStringStore implements StringPreferencesStore {
  SharedPreferencesStringStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> remove(String key) => _preferences.remove(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);
}

class JsonPlayerSaveRepository implements PlayerSaveRepository {
  JsonPlayerSaveRepository(this._store);

  static const String saveKey = 'fish_growth_player_save_v1';

  final StringPreferencesStore _store;

  @override
  Future<SaveLoadResult> load() async {
    final encoded = await _store.getString(saveKey);
    if (encoded == null) {
      return const SaveLoadResult(state: SaveLoadState.empty);
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Save root must be an object.');
      }
      return SaveLoadResult(
        state: SaveLoadState.loaded,
        data: PlayerSaveData.fromJson(decoded),
      );
    } on UnsupportedSaveVersion {
      return const SaveLoadResult(state: SaveLoadState.unsupportedVersion);
    } on FormatException {
      await _store.remove(saveKey);
      return const SaveLoadResult(state: SaveLoadState.recoveredCorrupt);
    }
  }

  @override
  Future<void> save(PlayerSaveData data) {
    return _store.setString(saveKey, jsonEncode(data.toJson()));
  }
}

class SharedPreferencesPlayerSaveRepository extends JsonPlayerSaveRepository {
  SharedPreferencesPlayerSaveRepository()
    : super(SharedPreferencesStringStore());
}

class NoopPlayerSaveRepository implements PlayerSaveRepository {
  const NoopPlayerSaveRepository();

  @override
  Future<SaveLoadResult> load() async {
    return const SaveLoadResult(state: SaveLoadState.empty);
  }

  @override
  Future<void> save(PlayerSaveData data) async {}
}
