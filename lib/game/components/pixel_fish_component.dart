import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class FishSpriteStrip {
  const FishSpriteStrip({
    required this.assetPath,
    required this.frameWidth,
    required this.frameHeight,
    this.frameCount = 4,
  });

  final String assetPath;
  final double frameWidth;
  final double frameHeight;
  final int frameCount;
}

class PixelFishComponent extends PositionComponent {
  PixelFishComponent({
    required super.position,
    required this.bodyColor,
    required this.speciesId,
    this.scaleFactor = 1,
    this.isPlayer = false,
  }) : super(
         size: Vector2(32 * scaleFactor, 20 * scaleFactor),
         anchor: Anchor.center,
       );

  Color bodyColor;
  final double scaleFactor;
  final bool isPlayer;
  String speciesId;
  Image? _spriteSheet;
  FishSpriteStrip? _spriteStrip;
  double _animationElapsed = 0;
  int _animationFrame = 0;

  static const Map<String, FishSpriteStrip> spriteStrips = {
    'starter_fish': FishSpriteStrip(
      assetPath: 'fish/starter_fish_swim_v001.png',
      frameWidth: 48,
      frameHeight: 32,
    ),
    'small_fish': FishSpriteStrip(
      assetPath: 'fish/small_fish_swim_v001.png',
      frameWidth: 48,
      frameHeight: 28,
    ),
    'puffer_fish': FishSpriteStrip(
      assetPath: 'fish/puffer_fish_swim_v001.png',
      frameWidth: 48,
      frameHeight: 48,
    ),
    'hunter_fish': FishSpriteStrip(
      assetPath: 'fish/hunter_fish_swim_v001.png',
      frameWidth: 64,
      frameHeight: 40,
    ),
  };

  int get animationFrame => _animationFrame;
  bool get hasSpriteVisual => _spriteSheet != null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(setSpeciesVisual(speciesId));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final strip = _spriteStrip;
    if (strip == null) {
      return;
    }
    _animationElapsed =
        (_animationElapsed + dt) % (strip.frameCount * _secondsPerFrame);
    _animationFrame =
        (_animationElapsed / _secondsPerFrame).floor() % strip.frameCount;
  }

  Future<void> setSpeciesVisual(String speciesId) async {
    this.speciesId = speciesId;
    _animationElapsed = 0;
    _animationFrame = 0;
    final strip = spriteStrips[speciesId];
    _spriteStrip = strip;
    _spriteSheet = null;
    if (strip == null || parent == null) {
      return;
    }

    final Image image;
    try {
      image = await Flame.images.load(strip.assetPath);
    } on Exception {
      return;
    }
    if (this.speciesId == speciesId) {
      _spriteSheet = image;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final unit = scaleFactor * 2;
    final dark = Paint()..color = const Color(0xFF071A2D);
    final body = Paint()..color = bodyColor;
    final highlight = Paint()..color = const Color(0xFFB8FFF1);
    final ring = Paint()
      ..color = const Color(0xFF5CFFB1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit;

    if (isPlayer) {
      canvas.drawRect(
        Rect.fromLTWH(unit, unit, size.x - unit * 2, size.y - unit * 2),
        ring,
      );
    }

    if (_renderSprite(canvas)) {
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(unit * 4, unit * 2, unit * 9, unit * 6),
      body,
    );
    canvas.drawRect(
      Rect.fromLTWH(unit * 2, unit * 3, unit * 3, unit * 4),
      body,
    );
    canvas.drawRect(Rect.fromLTWH(0, unit * 2, unit * 3, unit * 2), body);
    canvas.drawRect(Rect.fromLTWH(0, unit * 6, unit * 3, unit * 2), body);
    canvas.drawRect(
      Rect.fromLTWH(unit * 10, unit * 2, unit * 2, unit),
      highlight,
    );
    canvas.drawRect(Rect.fromLTWH(unit * 12, unit * 4, unit, unit), dark);
  }

  bool _renderSprite(Canvas canvas) {
    final image = _spriteSheet;
    final strip = _spriteStrip;
    if (image == null || strip == null) {
      return false;
    }

    final source = Rect.fromLTWH(
      _animationFrame * strip.frameWidth,
      0,
      strip.frameWidth,
      strip.frameHeight,
    );
    final isPuffer = speciesId == 'puffer_fish';
    final destination = isPuffer
        ? Rect.fromCenter(
            center: Offset(size.x / 2, size.y / 2),
            width: size.y * 1.35,
            height: size.y * 1.35,
          )
        : Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none,
    );
    return true;
  }

  static const double _secondsPerFrame = 0.14;
}
