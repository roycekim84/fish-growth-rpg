import 'dart:async';

import 'package:fish_growth_rpg/app/lifecycle/game_lifecycle_save_observer.dart';
import 'package:fish_growth_rpg/data/save/player_save_repository.dart';
import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:fish_growth_rpg/ui/collection/collection_overlay.dart';
import 'package:fish_growth_rpg/ui/hud/hud_overlay.dart';
import 'package:fish_growth_rpg/ui/species/species_change_overlay.dart';
import 'package:fish_growth_rpg/ui/quests/quest_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({this.saveRepository, super.key});

  final PlayerSaveRepository? saveRepository;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final FishGame _game;
  late final GameLifecycleSaveObserver _lifecycleObserver;

  static const double _webPortraitAspectRatio = 9 / 16;

  @override
  void initState() {
    super.initState();
    _game = FishGame(
      saveRepository:
          widget.saveRepository ?? SharedPreferencesPlayerSaveRepository(),
    );
    _lifecycleObserver = GameLifecycleSaveObserver(game: _game);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    unawaited(_game.saveNow());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: const Color(0xFF020A13),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth / constraints.maxHeight > 0.75;
            final gameSurface = ClipRect(
              child: GameWidget<FishGame>(
                game: _game,
                initialActiveOverlays: const [HudOverlay.overlayId],
                overlayBuilderMap: {
                  HudOverlay.overlayId: (context, game) =>
                      HudOverlay(game: game),
                  FishGame.collectionOverlayId: (context, game) =>
                      CollectionOverlay(game: game),
                  FishGame.speciesChangeOverlayId: (context, game) =>
                      SpeciesChangeOverlay(game: game),
                  FishGame.questOverlayId: (context, game) =>
                      QuestOverlay(game: game),
                },
                loadingBuilder: (context) => const _LoadingView(),
                errorBuilder: (context, error) => _ErrorView(error: error),
              ),
            );

            if (!isWide) {
              return gameSurface;
            }

            return Center(
              child: AspectRatio(
                aspectRatio: _webPortraitAspectRatio,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF194B65),
                      width: 2,
                    ),
                  ),
                  child: gameSurface,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF071A2D),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF32D6C4))),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF071A2D),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('게임을 불러오지 못했습니다.\n$error', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
