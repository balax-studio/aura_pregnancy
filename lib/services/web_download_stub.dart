import 'dart:typed_data';

/// Web harici platformlar için video kayıt stub'ı
Future<String?> recordAndDownloadVideoWeb({
  required List<Map<String, dynamic>> slidesData,
  required String fileName,
  void Function(double progress)? onProgress,
}) async {
  return null;
}

/// Web harici platformlar için indirme stub'ı (Mobil ve Masaüstü)
void downloadFileWeb(Uint8List bytes, String fileName) {}

/// Web harici platformlarda görsel indirme stub'ı.
void downloadImageWeb(Uint8List bytes, String fileName) {}
