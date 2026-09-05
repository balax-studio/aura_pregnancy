// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  const sourcePath =
      r'C:\Users\ismai\.gemini\antigravity-ide\brain\2c84689d-a3c1-4949-a385-f364c05c0775\aura_logo_clay_1788038754876.jpg';
  final sourceFile = File(sourcePath);

  if (!sourceFile.existsSync()) {
    print('Source logo file not found: $sourcePath');
    return;
  }

  final bytes = sourceFile.readAsBytesSync();

  // 1. Copy to assets/images/aura_logo.png
  final assetLogo = File('assets/images/aura_logo.png');
  assetLogo.writeAsBytesSync(bytes);
  print('Saved assets/images/aura_logo.png (${bytes.length} bytes)');

  // 2. Copy to Android launcher icons
  final mipmapDirs = [
    'android/app/src/main/res/mipmap-mdpi',
    'android/app/src/main/res/mipmap-hdpi',
    'android/app/src/main/res/mipmap-xhdpi',
    'android/app/src/main/res/mipmap-xxhdpi',
    'android/app/src/main/res/mipmap-xxxhdpi',
  ];

  for (final dir in mipmapDirs) {
    final iconFile = File('$dir/ic_launcher.png');
    if (!Directory(dir).existsSync()) {
      Directory(dir).createSync(recursive: true);
    }
    iconFile.writeAsBytesSync(bytes);
    print('Updated $dir/ic_launcher.png');
  }

  print('Logo installation completed successfully!');
}
