import 'package:fish_growth_rpg/domain/models/player_progress.dart';
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AutoHuntButton(game: game),
                const SizedBox(height: 10),
                _BoostButton(game: game),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuButton(
                    buttonKey: const ValueKey('collection-button'),
                    label: 'BOOK',
                    onTap: game.openCollection,
                  ),
                  const SizedBox(width: 8),
                  _MenuButton(
                    buttonKey: const ValueKey('species-change-button'),
                    label: 'CHANGE',
                    onTap: game.openSpeciesChange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.buttonKey,
    required this.label,
    required this.onTap,
  });

  final Key buttonKey;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: buttonKey,
        width: 62,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xEE0A3A5A),
          border: Border.all(color: const Color(0xFFFFD166), width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x99000000), offset: Offset(3, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFF0B8),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AutoHuntButton extends StatelessWidget {
  const _AutoHuntButton({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        game.world.autoHuntSystem.enabled,
        game.world.autoHuntSystem.status,
      ]),
      builder: (context, child) {
        final enabled = game.world.autoHuntSystem.enabled.value;
        final status = game.world.autoHuntSystem.status.value;
        return Semantics(
          button: true,
          toggled: enabled,
          label: '반자동 사냥',
          child: GestureDetector(
            onTap: () => game.setAutoHunting(!enabled),
            child: AnimatedContainer(
              key: const ValueKey('auto-hunt-button'),
              duration: const Duration(milliseconds: 100),
              width: 72,
              height: 50,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xEE3ACB8A)
                    : const Color(0xDD0A3A5A),
                border: Border.all(
                  color: enabled
                      ? const Color(0xFFFFF0B8)
                      : const Color(0xFF61AFFF),
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x99000000), offset: Offset(4, 4)),
                ],
              ),
              child: Center(
                child: Text(
                  enabled ? 'AUTO ON\n$status' : 'AUTO OFF\n$status',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: enabled
                        ? const Color(0xFF052C22)
                        : const Color(0xFFB8FFF1),
                    fontSize: 9,
                    height: 1.2,
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

class _StatusHud extends StatelessWidget {
  const _StatusHud({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([
            game.world.player.progressChanges,
            game.world.recoverySystem.isRecovering,
          ]),
          builder: (context, child) => _PixelPanel(
            child: Row(
              children: [
                const Expanded(
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
                Text(
                  game.world.recoverySystem.isRecovering.value
                      ? 'RECOVER'
                      : 'LV. ${game.world.player.progress.level}',
                  style: TextStyle(
                    color: game.world.recoverySystem.isRecovering.value
                        ? const Color(0xFF5CFFB1)
                        : const Color(0xFFF2F8FF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: Listenable.merge([
            game.world.player.hp,
            game.world.player.progressChanges,
          ]),
          builder: (context, child) => _StatusBar(
            label: 'HP',
            value: game.world.player.hp.value / game.world.player.maxHp,
            valueText:
                '${game.world.player.hp.value.ceil()} / ${game.world.player.maxHp.ceil()}',
            color: const Color(0xFFFF5C72),
          ),
        ),
        const SizedBox(height: 5),
        ValueListenableBuilder<int>(
          valueListenable: game.world.player.progressChanges,
          builder: (context, revision, child) => _StatusBar(
            label: 'FULL',
            value:
                game.world.player.progress.fullness /
                PlayerProgress.maxFullness,
            valueText:
                '${game.world.player.progress.fullness.ceil()} / ${PlayerProgress.maxFullness.ceil()}',
            color: const Color(0xFFFFC857),
          ),
        ),
        const SizedBox(height: 5),
        ValueListenableBuilder<int>(
          valueListenable: game.world.player.progressChanges,
          builder: (context, revision, child) => _StatusBar(
            label: 'EXP',
            value:
                game.world.player.progress.exp /
                game.world.player.progress.requiredExp,
            valueText:
                '${game.world.player.progress.exp} / ${game.world.player.progress.requiredExp}',
            color: const Color(0xFF61AFFF),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ValueListenableBuilder<String>(
            valueListenable: game.world.combatMessage,
            builder: (context, message, child) {
              return AnimatedOpacity(
                opacity: message.isEmpty ? 0 : 1,
                duration: const Duration(milliseconds: 100),
                child: _PixelPanel(
                  child: Text(
                    message.isEmpty ? ' ' : message,
                    style: const TextStyle(
                      color: Color(0xFFFFF0B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.bottomLeft,
          child: _PixelPanel(child: _PopulationStatus(game: game)),
        ),
      ],
    );
  }
}

class _PopulationStatus extends StatelessWidget {
  const _PopulationStatus({required this.game});

  final FishGame game;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        game.loadedSpeciesCount,
        game.world.npcCount,
        game.world.consumedFishCount,
        game.world.playerDefeatCount,
        game.world.player.progressChanges,
        game.saveStatus,
      ]),
      builder: (context, child) {
        return Text(
          'SPECIES  ${game.loadedSpeciesCount.value} / 3\n'
          'FORM  ${game.world.player.currentSpeciesName}\n'
          'NPC  ${game.world.npcCount.value} / 45\n'
          'EAT  ${game.world.player.progress.totalEaten}  '
          'KO  ${game.world.playerDefeatCount.value}\n'
          'STR  ${game.world.player.strength.toStringAsFixed(0)}  '
          'SIZE  ${game.world.player.gameplaySize.toStringAsFixed(2)}\n'
          'SAVE  ${game.saveStatus.value.label}',
          style: const TextStyle(
            color: Color(0xFFB8FFF1),
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w800,
          ),
        );
      },
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
    required this.valueText,
    required this.color,
  });

  final String label;
  final double value;
  final String valueText;
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: value.clamp(0, 1),
                      heightFactor: 1,
                      child: ColoredBox(color: color),
                    ),
                  ),
                  Center(
                    child: Text(
                      valueText,
                      style: const TextStyle(
                        color: Color(0xFFF2F8FF),
                        fontSize: 8,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Color(0xFF07101D), blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
