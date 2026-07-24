import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class OceanBackdrop extends PositionComponent {
  OceanBackdrop()
    : super(
        position: Vector2(-720, -960),
        size: Vector2(1440, 1920),
        priority: -100,
      );

  static const double _tileSize = 256;
  static const double _propCellSize = 64;
  static const List<_OceanPropPlacement> _propPlacements = [
    _OceanPropPlacement(0, 70, 210, 82),
    _OceanPropPlacement(4, 1180, 180, 76),
    _OceanPropPlacement(2, 290, 470, 92),
    _OceanPropPlacement(6, 980, 520, 72),
    _OceanPropPlacement(1, 560, 760, 88),
    _OceanPropPlacement(5, 1270, 810, 84),
    _OceanPropPlacement(3, 130, 1080, 98),
    _OceanPropPlacement(7, 760, 1120, 78),
    _OceanPropPlacement(4, 1110, 1420, 72),
    _OceanPropPlacement(0, 390, 1510, 86),
    _OceanPropPlacement(2, 860, 1740, 96),
    _OceanPropPlacement(5, 90, 1810, 80),
  ];

  double _bubbleOffset = 0;
  Image? _waterTile;
  Image? _propsAtlas;
  OceanBackdropTheme _theme = OceanBackdropTheme.shallows;

  void setTheme(OceanBackdropTheme theme) {
    _theme = theme;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(_loadAssets());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bubbleOffset = (_bubbleOffset + dt * 7) % 96;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = _theme.baseColor,
    );

    _drawWaterTexture(canvas);
    _drawProps(canvas);
    _drawParticles(canvas);
  }

  Future<void> _loadAssets() async {
    try {
      final images = await Future.wait([
        Flame.images.load('environment/ocean_water_tile_v001.png'),
        Flame.images.load('environment/ocean_props_atlas_v001.png'),
      ]);
      _waterTile = images[0];
      _propsAtlas = images[1];
    } on Exception {
      // The flat ocean color remains a valid low-cost fallback.
    }
  }

  void _drawWaterTexture(Canvas canvas) {
    final image = _waterTile;
    if (image == null) {
      return;
    }
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;
    for (var y = 0.0; y < size.y; y += _tileSize) {
      for (var x = 0.0; x < size.x; x += _tileSize) {
        canvas.drawImageRect(
          image,
          source,
          Rect.fromLTWH(x, y, _tileSize, _tileSize),
          paint,
        );
      }
    }
  }

  void _drawProps(Canvas canvas) {
    final image = _propsAtlas;
    if (image == null) {
      return;
    }
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;
    for (final prop in _propPlacements) {
      final column = prop.index % 4;
      final row = prop.index ~/ 4;
      final source = Rect.fromLTWH(
        column * _propCellSize,
        row * _propCellSize,
        _propCellSize,
        _propCellSize,
      );
      canvas.drawImageRect(
        image,
        source,
        Rect.fromLTWH(prop.x, prop.y, prop.displaySize, prop.displaySize),
        paint,
      );
    }
  }

  void _drawParticles(Canvas canvas) {
    final speckPaint = Paint()..color = _theme.particleColor;
    final bubblePaint = Paint()
      ..color = const Color(0x887CD6E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var y = 20.0 - _bubbleOffset; y < size.y; y += 96) {
      final offset = ((y / 96).floor().isEven) ? 12.0 : 52.0;
      for (var x = offset; x < size.x; x += 128) {
        canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), speckPaint);
        if (((x + y) / 32).floor().isEven) {
          canvas.drawRect(Rect.fromLTWH(x + 22, y + 34, 5, 5), bubblePaint);
          canvas.drawRect(Rect.fromLTWH(x + 23, y + 35, 1, 1), speckPaint);
        }
      }
    }
  }
}

enum OceanBackdropTheme {
  shallows(Color(0xFF0A3A5A), Color(0x6632D6C4)),
  deepSea(Color(0xFF07132D), Color(0x555D7CFF));

  const OceanBackdropTheme(this.baseColor, this.particleColor);

  final Color baseColor;
  final Color particleColor;
}

class _OceanPropPlacement {
  const _OceanPropPlacement(this.index, this.x, this.y, this.displaySize);

  final int index;
  final double x;
  final double y;
  final double displaySize;
}
