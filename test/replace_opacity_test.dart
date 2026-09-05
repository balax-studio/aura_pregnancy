// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Replace withOpacity', () {
    final dir = Directory('lib');
    final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    final opacityRegex = RegExp(r'\.withOpacity\(([^)]+)\)');
    
    for (final file in files) {
      String content = file.readAsStringSync();
      if (content.contains('.withValues(alpha: ')) {
        content = content.replaceAllMapped(opacityRegex, (match) {
          return '.withValues(alpha: ${match.group(1)})';
        });
        file.writeAsStringSync(content);
        print('Updated \${file.path}');
      }
    }

    final testDir = Directory('test');
    final testFiles = testDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final file in testFiles) {
      String content = file.readAsStringSync();
      if (content.contains('.withValues(alpha: ')) {
        content = content.replaceAllMapped(opacityRegex, (match) {
          return '.withValues(alpha: ${match.group(1)})';
        });
        file.writeAsStringSync(content);
        print('Updated \${file.path}');
      }
    }
  });
}
