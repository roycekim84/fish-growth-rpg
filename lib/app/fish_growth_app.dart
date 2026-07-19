import 'package:fish_growth_rpg/data/save/player_save_repository.dart';
import 'package:fish_growth_rpg/ui/game_screen.dart';
import 'package:flutter/material.dart';

class FishGrowthApp extends StatelessWidget {
  const FishGrowthApp({this.saveRepository, super.key});

  final PlayerSaveRepository? saveRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Growth RPG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF32D6C4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071A2D),
        useMaterial3: true,
      ),
      home: GameScreen(saveRepository: saveRepository),
    );
  }
}
