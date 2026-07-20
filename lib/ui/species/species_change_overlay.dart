import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:fish_growth_rpg/game/fish_world.dart';
import 'package:fish_growth_rpg/ui/theme/pixel_ui.dart';
import 'package:flutter/material.dart';

class SpeciesChangeOverlay extends StatefulWidget {
  const SpeciesChangeOverlay({required this.game, super.key});

  final FishGame game;

  @override
  State<SpeciesChangeOverlay> createState() => _SpeciesChangeOverlayState();
}

class _SpeciesChangeOverlayState extends State<SpeciesChangeOverlay> {
  late String selectedSpeciesId =
      widget.game.world.player.progress.currentSpeciesId;
  String feedback = '';

  @override
  Widget build(BuildContext context) {
    final progress = widget.game.world.player.progress;
    final options = <FishSpecies?>[null, ...widget.game.species];
    final selectedSpecies = selectedSpeciesId == PlayerProgress.starterSpeciesId
        ? null
        : widget.game.species
              .where((species) => species.id == selectedSpeciesId)
              .firstOrNull;
    final selectedUnlocked = progress.isSpeciesUnlocked(selectedSpeciesId);
    final isCurrent = progress.currentSpeciesId == selectedSpeciesId;

    return ColoredBox(
      color: const Color(0xF2071A2D),
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Column(
          children: [
            PixelHeader(
              title: 'SPECIES CHANGE',
              closeButtonKey: const ValueKey('species-close-button'),
              onClose: () =>
                  widget.game.closeModal(FishGame.speciesChangeOverlayId),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: options.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final species = options[index];
                  final id = species?.id ?? PlayerProgress.starterSpeciesId;
                  final unlocked = progress.isSpeciesUnlocked(id);
                  final current = progress.currentSpeciesId == id;
                  return _SpeciesOption(
                    key: ValueKey('species-option-$id'),
                    speciesId: id,
                    name: species?.displayName ?? '푸른 치어',
                    unlocked: unlocked,
                    current: current,
                    selected: selectedSpeciesId == id,
                    count: species == null
                        ? null
                        : progress.eatenCountBySpeciesId[id] ?? 0,
                    goal: species?.unlockEatCount,
                    onTap: () => setState(() {
                      selectedSpeciesId = id;
                      feedback = '';
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _PreviewPanel(
                species: selectedSpecies,
                progress: progress,
              ),
            ),
            if (feedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  feedback,
                  style: const TextStyle(
                    color: Color(0xFFFF5C72),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: PixelButton(
                key: const ValueKey('confirm-species-change-button'),
                label: isCurrent
                    ? 'CURRENT SPECIES'
                    : selectedUnlocked
                    ? 'CHANGE SPECIES'
                    : 'LOCKED',
                onPressed: !selectedUnlocked || isCurrent
                    ? null
                    : _confirmChange,
                width: double.infinity,
                height: 50,
                accent: PixelPalette.teal,
                activeColor: PixelPalette.teal,
                foregroundColor: const Color(0xFF052C22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmChange() {
    final result = widget.game.changeSpecies(selectedSpeciesId);
    if (result == SpeciesChangeResult.success) {
      widget.game.closeModal(FishGame.speciesChangeOverlayId);
      return;
    }
    setState(() {
      feedback = switch (result) {
        SpeciesChangeResult.locked => '아직 해금되지 않은 종입니다.',
        SpeciesChangeResult.inCombat => '전투 중에는 종변화할 수 없습니다.',
        SpeciesChangeResult.notFound => '종 데이터를 찾을 수 없습니다.',
        SpeciesChangeResult.success => '',
      };
    });
  }
}

class _SpeciesOption extends StatelessWidget {
  const _SpeciesOption({
    required this.speciesId,
    required this.name,
    required this.unlocked,
    required this.current,
    required this.selected,
    required this.count,
    required this.goal,
    required this.onTap,
    super.key,
  });

  final String speciesId;
  final String name;
  final bool unlocked;
  final bool current;
  final bool selected;
  final int? count;
  final int? goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 104,
        child: PixelPanel(
          shadow: false,
          padding: const EdgeInsets.all(6),
          accent: selected ? PixelPalette.cream : const Color(0xFF315C72),
          background: selected
              ? const Color(0xFF164E68)
              : const Color(0xFF0A2B43),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelFishPortrait(
                speciesId: speciesId,
                unlocked: unlocked,
                width: 58,
                height: 36,
              ),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                current
                    ? '■ CURRENT'
                    : !unlocked
                    ? '× ${count ?? 0} / ${goal ?? 100}'
                    : '◆ UNLOCKED',
                style: TextStyle(
                  color: current
                      ? PixelPalette.gold
                      : unlocked
                      ? PixelPalette.green
                      : PixelPalette.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.species, required this.progress});

  final FishSpecies? species;
  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    final hpMultiplier = species?.playerMaxHpMultiplier ?? 1;
    final strMultiplier = species?.playerStrengthMultiplier ?? 1;
    final speedMultiplier = species?.playerSpeedMultiplier ?? 1;
    final sizeMultiplier = species?.playerSizeMultiplier ?? 1;
    final weightMultiplier = species?.playerWeightMultiplier ?? 1;
    final trait =
        species?.playerTraitDescription ?? '균형 잡힌 기본 능력으로 모든 상황에 대응하는 시작 종이다.';
    final abilityName = species?.playerAbilityName ?? '균형 유영';
    final abilityDescription =
        species?.playerAbilityDescription ?? '아직 특정 지형을 통과하는 고유 능력은 없다.';

    final speciesId = species?.id ?? PlayerProgress.starterSpeciesId;
    return PixelPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PixelFishPortrait(speciesId: speciesId, width: 82, height: 54),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  species?.displayName ?? '푸른 치어',
                  style: const TextStyle(
                    color: PixelPalette.cream,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'MAX HP  ${(progress.maxHp * hpMultiplier).round()}   '
            'STR  ${(progress.strength * strMultiplier).toStringAsFixed(1)}\n'
            'SIZE  ${(progress.size * sizeMultiplier).toStringAsFixed(2)}   '
            'WEIGHT  ${(progress.weight * weightMultiplier).toStringAsFixed(2)}\n'
            'SPEED  ×${speedMultiplier.toStringAsFixed(2)}',
            style: const TextStyle(height: 1.7, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            trait,
            style: const TextStyle(color: Color(0xFFB7C8D6), height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'ABILITY  $abilityName',
            style: const TextStyle(
              color: PixelPalette.gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            abilityDescription,
            style: const TextStyle(
              color: PixelPalette.mint,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
