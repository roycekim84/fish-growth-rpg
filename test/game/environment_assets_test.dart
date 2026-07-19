import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packages the compact water tile and environment prop atlas', () async {
    final water = await _decodeAsset(
      'assets/images/environment/ocean_water_tile_v001.png',
    );
    final props = await _decodeAsset(
      'assets/images/environment/ocean_props_atlas_v001.png',
    );

    expect((water.width, water.height), (256, 256));
    expect((props.width, props.height), (256, 128));

    water.dispose();
    props.dispose();
  });
}

Future<ui.Image> _decodeAsset(String path) async {
  final data = await rootBundle.load(path);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}
