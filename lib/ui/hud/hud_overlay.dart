import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:flutter/material.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({required this.game, super.key});

  static const String overlayId = 'hud';

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Stack(
        children: [
          IgnorePointer(child: _StatusHud(game: game)),
          Align(
            alignment: Alignment.bottomRight,
            child: _BoostButton(game: game),
          ),
        ],
      ),
    );
  }
}

class _StatusHud extends StatelessWidget {
  const _StatusHud({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PixelPanel(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'FISH GROWTH RPG',
                  style: TextStyle(
                    color: Color(0xFFB8FFF1),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              Text('LV. 1', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const _StatusBar(label: 'HP', value: 0.82, color: Color(0xFFFF5C72)),
        const SizedBox(height: 5),
        const _StatusBar(label: 'FULL', value: 0.55, color: Color(0xFFFFC857)),
        const SizedBox(height: 5),
        const _StatusBar(label: 'EXP', value: 0.25, color: Color(0xFF61AFFF)),
        const Spacer(),
        Align(
          alignment: Alignment.bottomLeft,
          child: _PixelPanel(
            child: ValueListenableBuilder<int>(
              valueListenable: game.world.npcCount,
              builder: (context, npcCount, child) =>
                  ValueListenableBuilder<int>(
                    valueListenable: game.loadedSpeciesCount,
                    builder: (context, speciesCount, child) {
                      return Text(
                        'SPECIES  $speciesCount / 3\nNPC  $npcCount / 45',
                        style: const TextStyle(
                          color: Color(0xFFB8FFF1),
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BoostButton extends StatelessWidget {
  const _BoostButton({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.boostState,
      builder: (context, isBoosting, child) {
        return Semantics(
          button: true,
          label: '부스터',
          child: Listener(
            onPointerDown: (_) => game.setBoosting(true),
            onPointerUp: (_) => game.setBoosting(false),
            onPointerCancel: (_) => game.setBoosting(false),
            child: AnimatedContainer(
              key: const ValueKey('boost-button'),
              duration: const Duration(milliseconds: 80),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isBoosting
                    ? const Color(0xEEFFB347)
                    : const Color(0xDD0A3A5A),
                border: Border.all(
                  color: isBoosting
                      ? const Color(0xFFFFF0B8)
                      : const Color(0xFF32D6C4),
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x99000000), offset: Offset(4, 4)),
                ],
              ),
              child: Center(
                child: Text(
                  isBoosting ? 'BOOST!' : 'BOOST',
                  style: TextStyle(
                    color: isBoosting
                        ? const Color(0xFF452A00)
                        : const Color(0xFFB8FFF1),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PixelPanel extends StatelessWidget {
  const _PixelPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xDD071A2D),
        border: Border.all(color: const Color(0xFF32D6C4), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x88000000), offset: Offset(3, 3)),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15,
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF07101D),
                border: Border.all(color: const Color(0xFFB8FFF1)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  heightFactor: 1,
                  child: ColoredBox(color: color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
