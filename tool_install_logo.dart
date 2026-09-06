// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final sourceFile = File('assets/images/logo.png');

  if (!sourceFile.existsSync()) {
    print('Source logo file not found: assets/images/logo.png');
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
