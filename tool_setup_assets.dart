// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';

void main() {
  final targetImgDir = Directory('d:/github/hamilelik-app/assets/images');
  final targetAudioDir = Directory('d:/github/hamilelik-app/assets/audio');

  if (!targetImgDir.existsSync()) targetImgDir.createSync(recursive: true);
  if (!targetAudioDir.existsSync()) targetAudioDir.createSync(recursive: true);

  // Copy images
  final brainDir = Directory('C:/Users/ismai/.gemini/antigravity-ide/brain/3e2acc54-c6e1-4f30-ba93-d2b6a8bfbdb2');
  final files = brainDir.listSync();
  for (var f in files) {
    if (f is File && f.path.contains('sample_ultrasound')) {
      f.copySync('d:/github/hamilelik-app/assets/images/sample_ultrasound.png');
      f.copySync('d:/github/hamilelik-app/assets/images/sample_ultrasound.jpg');
      print('Copied sample_ultrasound');
    }
    if (f is File && f.path.contains('aura_app_logo')) {
      f.copySync('d:/github/hamilelik-app/assets/images/aura_logo.png');
      f.copySync('d:/github/hamilelik-app/assets/images/aura_logo.jpg');
      print('Copied aura_logo');
    }
  }

  // Create valid MP3 / Audio dummy files
  final audioFile = File('d:/github/hamilelik-app/assets/audio/Aura_Lullaby.mp3');
  final voiceFile = File('d:/github/hamilelik-app/assets/audio/voice_letter.m4a');

  // Minimal valid MP3 header bytes (MPEG-1 Audio Layer 3 silence / sync frame)
  final mp3Bytes = Uint8List.fromList([
    0xFF, 0xFB, 0x90, 0x64, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x49, 0x6E, 0x66, 0x6F, 0x00, 0x00, 0x00, 0x0F,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00
  ]);

  audioFile.writeAsBytesSync(mp3Bytes);
  voiceFile.writeAsBytesSync(mp3Bytes);
  print('Created audio assets');
}
