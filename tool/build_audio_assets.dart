import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _sampleRate = 22050;

void main() {
  final output = Directory('assets/audio')..createSync(recursive: true);
  _writeWave(
    File('${output.path}/bite_v001.wav'),
    _sequence([
      _tone(860, 0.045, volume: 0.30, square: true),
      _tone(430, 0.075, volume: 0.24, square: true),
    ]),
  );
  _writeWave(
    File('${output.path}/consume_v001.wav'),
    _sequence([
      _tone(440, 0.07, volume: 0.22, square: true),
      _tone(660, 0.07, volume: 0.24, square: true),
      _tone(880, 0.11, volume: 0.20, square: true),
    ]),
  );
  _writeWave(
    File('${output.path}/level_up_v001.wav'),
    _sequence([
      _tone(523.25, 0.10, volume: 0.20, square: true),
      _tone(659.25, 0.10, volume: 0.22, square: true),
      _tone(783.99, 0.10, volume: 0.24, square: true),
      _tone(1046.50, 0.20, volume: 0.20, square: true),
    ]),
  );
  _writeWave(
    File('${output.path}/defeat_v001.wav'),
    _sequence([
      _tone(330, 0.11, volume: 0.24, square: true),
      _tone(247, 0.11, volume: 0.22, square: true),
      _tone(165, 0.22, volume: 0.20, square: true),
    ]),
  );
}

List<double> _tone(
  double frequency,
  double seconds, {
  required double volume,
  bool square = false,
}) {
  final length = (_sampleRate * seconds).round();
  return List<double>.generate(length, (index) {
    final phase = 2 * math.pi * frequency * index / _sampleRate;
    final wave = square ? (math.sin(phase) >= 0 ? 1.0 : -1.0) : math.sin(phase);
    final envelope = math.sin(math.pi * index / math.max(1, length - 1));
    return wave * envelope * volume;
  }, growable: false);
}

List<double> _sequence(List<List<double>> parts) => [
  for (final part in parts) ...part,
];

void _writeWave(File file, List<double> samples) {
  const channelCount = 1;
  const bitsPerSample = 16;
  final dataSize = samples.length * 2;
  final bytes = ByteData(44 + dataSize);

  void ascii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, channelCount, Endian.little);
  bytes.setUint32(24, _sampleRate, Endian.little);
  bytes.setUint32(28, _sampleRate * channelCount * 2, Endian.little);
  bytes.setUint16(32, channelCount * 2, Endian.little);
  bytes.setUint16(34, bitsPerSample, Endian.little);
  ascii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final value = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    bytes.setInt16(44 + i * 2, value, Endian.little);
  }
  file.writeAsBytesSync(bytes.buffer.asUint8List(), flush: true);
}
