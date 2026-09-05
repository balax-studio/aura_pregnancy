// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final brainDir = Directory(r'C:\Users\ismai\.gemini\antigravity-ide\brain\c0e508e4-b79f-4fce-8d71-f1f92fed0f88');
  final targetDir = Directory(r'd:\github\hamilelik-app\assets\images');

  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  final files = brainDir.listSync().whereType<File>().toList();

  for (int stage = 1; stage <= 6; stage++) {
    final stageFiles = files.where((f) => f.path.contains('womb_stage_${stage}_') && f.path.endsWith('.jpg')).toList();
    if (stageFiles.isNotEmpty) {
      stageFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final srcFile = stageFiles.first;
      final targetFile = File('${targetDir.path}\\womb_stage$stage.jpg');
      srcFile.copySync(targetFile.path);
      print('Copied Stage $stage: ${srcFile.path} -> ${targetFile.path} (${targetFile.lengthSync()} bytes)');
    }
  }
}
