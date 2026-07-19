import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:fish_growth_rpg/game/fish_world.dart';
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
            _SpeciesHeader(
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
                    name: species?.displayName ?? '푸른 치어',
                    color: PlayerFishComponent.colorForSpecies(id),
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
              child: FilledButton(
                key: const ValueKey('confirm-species-change-button'),
                onPressed: !selectedUnlocked || isCurrent
                    ? null
                    : _confirmChange,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF32D6C4),
                  foregroundColor: const Color(0xFF052C22),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  isCurrent
                      ? 'CURRENT SPECIES'
                      : selectedUnlocked
                      ? 'CHANGE SPECIES'
                      : 'LOCKED',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
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

class _SpeciesHeader extends StatelessWidget {
  const _SpeciesHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3A5A),
        border: Border.all(color: const Color(0xFF32D6C4), width: 3),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'SPECIES CHANGE',
              style: TextStyle(
                color: Color(0xFFB8FFF1),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('species-close-button'),
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Color(0xFFFFF0B8)),
          ),
        ],
      ),
    );
  }
}

class _SpeciesOption extends StatelessWidget {
  const _SpeciesOption({
    required this.name,
    required this.color,
    required this.unlocked,
    required this.current,
    required this.selected,
    required this.count,
    required this.goal,
    required this.onTap,
    super.key,
  });

  final String name;
  final Color color;
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
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF164E68) : const Color(0xFF0A2B43),
          border: Border.all(
            color: selected ? const Color(0xFFFFF0B8) : const Color(0xFF315C72),
            width: selected ? 3 : 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 24,
              color: unlocked ? color : const Color(0xFF152A38),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
            Text(
              current
                  ? 'CURRENT'
                  : count == null
                  ? 'UNLOCKED'
                  : '$count / $goal',
              style: TextStyle(
                color: unlocked
                    ? const Color(0xFF5CFFB1)
                    : const Color(0xFF78909C),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xEE0A2B43),
        border: Border.all(color: const Color(0xFF32D6C4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            species?.displayName ?? '푸른 치어',
            style: const TextStyle(
              color: Color(0xFFFFF0B8),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}
