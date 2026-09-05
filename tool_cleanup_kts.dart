// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final kts1 = File('d:/github/hamilelik-app/android/settings.gradle.kts');
  final kts2 = File('d:/github/hamilelik-app/android/build.gradle.kts');
  final kts3 = File('d:/github/hamilelik-app/android/app/build.gradle.kts');

  if (kts1.existsSync()) kts1.deleteSync();
  if (kts2.existsSync()) kts2.deleteSync();
  if (kts3.existsSync()) kts3.deleteSync();

  print('KTS files successfully deleted.');
}
