import 'dart:async';

import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:flutter/widgets.dart';

class GameLifecycleSaveObserver with WidgetsBindingObserver {
  GameLifecycleSaveObserver({required this.game});

  final FishGame game;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(saveForState(state));
  }

  Future<void> saveForState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      return game.saveNow();
    }
    return Future<void>.value();
  }
}
