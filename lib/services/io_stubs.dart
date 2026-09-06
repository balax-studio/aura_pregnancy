import 'dart:typed_data';

/// Web ortamında dart:io kütüphanesi derleme hatası vermesin diye oluşturulan stub.
class File {
  final String path;
  File(this.path);
  bool existsSync() => false;
  Future<bool> exists() async => false;
  Future<void> delete() async {}
  Future<File> copy(String path) async => this;
  Future<File> writeAsBytes(List<int> bytes, {bool flush = false}) async => this;
  void writeAsBytesSync(List<int> bytes, {bool flush = false}) {}
  Future<File> writeAsString(String contents, {bool flush = false}) async => this;
  void writeAsStringSync(String contents, {bool flush = false}) {}
  Future<Uint8List> readAsBytes() async => Uint8List(0);
  Uint8List readAsBytesSync() => Uint8List(0);
  Future<String> readAsString() async => '';
  String readAsStringSync() => '';
  Future<int> length() async => 0;
  int lengthSync() => 0;
}

class Directory {
  final String path;
  Directory(this.path);
  bool existsSync() => false;
  Future<bool> exists() async => false;
  Future<void> create({bool recursive = false}) async {}
  void createSync({bool recursive = false}) {}
  Future<void> delete({bool recursive = false}) async {}
}

class Platform {
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static Map<String, String> get environment => const {};
}
