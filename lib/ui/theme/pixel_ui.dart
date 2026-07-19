import 'package:flutter/material.dart';

abstract final class PixelPalette {
  static const ink = Color(0xFF020A13);
  static const navy = Color(0xFF071A2D);
  static const panel = Color(0xF20A2B43);
  static const panelLight = Color(0xFF0D3D59);
  static const teal = Color(0xFF32D6C4);
  static const mint = Color(0xFFB8FFF1);
  static const cream = Color(0xFFFFF0B8);
  static const gold = Color(0xFFFFD166);
  static const blue = Color(0xFF61AFFF);
  static const green = Color(0xFF5CFFB1);
  static const red = Color(0xFFFF5C72);
  static const muted = Color(0xFF78909C);
}

class PixelPanel extends StatelessWidget {
  const PixelPanel({
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.accent = PixelPalette.teal,
    this.background = PixelPalette.panel,
    this.shadow = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color accent;
  final Color background;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PixelPalette.ink,
        border: Border.all(color: PixelPalette.ink, width: 2),
        boxShadow: shadow
            ? const [BoxShadow(color: Color(0x99000000), offset: Offset(4, 4))]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: accent, width: 2),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class PixelButton extends StatefulWidget {
  const PixelButton({
    required this.label,
    required this.onPressed,
    this.width,
    this.height = 42,
    this.accent = PixelPalette.gold,
    this.activeColor = PixelPalette.panelLight,
    this.foregroundColor = PixelPalette.cream,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final Color accent;
  final Color activeColor;
  final Color foregroundColor;
  final String? semanticLabel;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final accent = enabled ? widget.accent : const Color(0xFF315C72);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(
            _pressed ? 2 : 0,
            _pressed ? 2 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: PixelPalette.ink,
            border: Border.all(color: PixelPalette.ink, width: 2),
            boxShadow: _pressed
                ? null
                : const [
                    BoxShadow(color: Color(0x99000000), offset: Offset(3, 3)),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: enabled ? widget.activeColor : const Color(0xFF152A38),
                border: Border.all(color: accent, width: 2),
              ),
              child: Center(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: enabled
                        ? widget.foregroundColor
                        : PixelPalette.muted,
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PixelProgressBar extends StatelessWidget {
  const PixelProgressBar({
    required this.value,
    required this.valueText,
    required this.color,
    super.key,
  });

  final double value;
  final String valueText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF07101D),
        border: Border.all(color: PixelPalette.ink, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
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
            Row(
              children: List.generate(
                10,
                (index) => Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 1,
                      height: double.infinity,
                      child: ColoredBox(
                        color: index == 9
                            ? Colors.transparent
                            : const Color(0x55020A13),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                valueText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: PixelPalette.ink, blurRadius: 2)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelFishPortrait extends StatelessWidget {
  const PixelFishPortrait({
    required this.speciesId,
    this.unlocked = true,
    this.width = 58,
    this.height = 42,
    super.key,
  });

  final String speciesId;
  final bool unlocked;
  final double width;
  final double height;

  static const Map<String, String> _assets = {
    'starter_fish': 'assets/images/fish/starter_fish_swim_v001.png',
    'small_fish': 'assets/images/fish/small_fish_swim_v001.png',
    'puffer_fish': 'assets/images/fish/puffer_fish_swim_v001.png',
    'hunter_fish': 'assets/images/fish/hunter_fish_swim_v001.png',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assets[speciesId] ?? _assets['starter_fish']!;
    return ColorFiltered(
      colorFilter: unlocked
          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
          : const ColorFilter.mode(Color(0xFF152A38), BlendMode.saturation),
      child: ClipRect(
        child: SizedBox(
          width: width,
          height: height,
          child: Transform.scale(
            scaleX: 4,
            alignment: Alignment.centerLeft,
            child: Image.asset(
              asset,
              width: width,
              height: height,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }
}

class PixelHeader extends StatelessWidget {
  const PixelHeader({
    required this.title,
    required this.onClose,
    required this.closeButtonKey,
    super.key,
  });

  final String title;
  final VoidCallback onClose;
  final Key closeButtonKey;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.fromLTRB(10, 5, 3, 5),
      child: Row(
        children: [
          const Text(
            '◆',
            style: TextStyle(color: PixelPalette.gold, fontSize: 10),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: PixelPalette.mint,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ),
          PixelButton(
            key: closeButtonKey,
            label: 'X',
            semanticLabel: '닫기',
            width: 40,
            height: 34,
            accent: PixelPalette.red,
            foregroundColor: PixelPalette.cream,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
