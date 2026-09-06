import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' if (dart.library.html) 'io_stubs.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/constants/app_colors.dart';
import '../core/theme/clay_theme.dart';

/// Aura Pregnancy - Medya ve Fotoğraf Yönetim Servisi
class MediaService {
  MediaService._internal();
  static final MediaService instance = MediaService._internal();

  static const MethodChannel _galleryChannel = MethodChannel('com.balaxstudio.aura/gallery');
  final ImagePicker _picker = ImagePicker();

  /// Görseli cihaza / galeriye kaydeder (iOS'ta Fotoğraflar / Camera Roll, Android'de MediaStore Fotoğraflar albümü)
  Future<bool> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileNamePrefix,
  }) async {
    if (kIsWeb) return false;

    // Mobil (Android & iOS): Yerel MethodChannel ile doğrudan sistem galerisine kaydet
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final success = await _galleryChannel.invokeMethod<bool>(
          'saveImageToGallery',
          {
            'imageBytes': imageBytes,
            'fileNamePrefix': fileNamePrefix,
          },
        );
        if (success == true) {
          return true;
        }
      } catch (e) {
        debugPrint('Native saveImageToGallery error: $e');
      }
    }

    // Güvenli Fallback: Uygulama belgeler dizinine kaydet
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);
      return true;
    } catch (e) {
      debugPrint('Error saving file to disk fallback: $e');
      return false;
    }
  }

  /// Fotoğraf Seçim Diyaloğu (Galeri ve Kamera)
  Future<String?> showPhotoPickerDialog(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Tutamaç
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.camera_alt_rounded, color: AppColors.primaryPink, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'media_picker_title'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'media_picker_subtitle'.tr(),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),

              // 1. Seçenek: Galeriden Fotoğraf Seç
              _buildActionTile(
                icon: Icons.photo_library_rounded,
                iconColor: AppColors.primaryPink,
                backgroundColor: AppColors.clayRose,
                title: 'media_picker_gallery_title'.tr(),
                subtitle: 'media_picker_gallery_desc'.tr(),
                onTap: () async {
                  final path = await pickImageFromGallery(context);
                  if (ctx.mounted) {
                    Navigator.pop(ctx, path);
                  }
                },
              ),
              const SizedBox(height: 10),

              // 2. Seçenek: Kameradan Fotoğraf Çek
              _buildActionTile(
                icon: Icons.camera_alt_rounded,
                iconColor: AppColors.secondaryPeach,
                backgroundColor: AppColors.clayPeach,
                title: 'media_picker_camera_title'.tr(),
                subtitle: 'media_picker_camera_desc'.tr(),
                onTap: () async {
                  final path = await captureImageFromCamera(context);
                  if (ctx.mounted) {
                    Navigator.pop(ctx, path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: ClayTheme.clayDecoration(
                    color: Colors.white,
                    borderRadius: 14,
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: iconColor.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Galeriden Fotoğraf Seçme ve İzin Akışı
  Future<String?> pickImageFromGallery(BuildContext context) async {
    try {
      // İzin kontrolü (Mobilde)
      if (!kIsWeb) {
        final hasPermission = await _requestGalleryPermission(context);
        if (!hasPermission) return null;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        return pickedFile.path;
      }

      // Mobilde fotoğrafı uygulamanın kalıcı belgeler dizinine kopyala
      return await _saveFileLocally(pickedFile);
    } catch (e) {
      debugPrint('pickImageFromGallery error: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Fotoğraf seçilirken bir sorun oluştu: $e');
      }
      return null;
    }
  }

  /// Kameradan Fotoğraf Çekme ve İzin Akışı
  Future<String?> captureImageFromCamera(BuildContext context) async {
    try {
      // Kamera izni kontrolü (Mobilde)
      if (!kIsWeb) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus.isPermanentlyDenied) {
          if (context.mounted) {
            _showPermissionDialog(context, 'media_perm_camera_title'.tr(), 'media_perm_camera_desc'.tr());
          }
          return null;
        }
        if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
          if (context.mounted) {
            _showErrorSnackBar(context, 'media_error_camera_req'.tr());
          }
          return null;
        }
      }

      final XFile? capturedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (capturedFile == null) return null;

      if (kIsWeb) {
        return capturedFile.path;
      }

      return await _saveFileLocally(capturedFile);
    } catch (e) {
      debugPrint('captureImageFromCamera error: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Fotoğraf çekilirken bir sorun oluştu: $e');
      }
      return null;
    }
  }

  /// Galeri İzni Kontrolü
  /// Android'de modern Photo Picker kullanılır ve herhangi bir izin gerektirmez.
  /// iOS'ta sistem fotoğraf erişimi kontrol edilir.
  Future<bool> _requestGalleryPermission(BuildContext context) async {
    if (kIsWeb || Platform.isAndroid) return true;

    final status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(context, 'media_perm_gallery_title'.tr(), 'media_perm_gallery_desc'.tr());
      }
      return false;
    }

    if (context.mounted) {
      _showErrorSnackBar(context, 'media_error_gallery_req'.tr());
    }
    return false;
  }

  /// Seçilen resmi yerel kalıcı dizine güvenli şekilde kaydeder (Mobil)
  /// Scoped Storage ve izin kısıtlamalarına takılmamak için XFile.readAsBytes kullanılır.
  Future<String> _saveFileLocally(XFile pickedFile) async {
    if (kIsWeb) return pickedFile.path;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final memoriesDir = Directory(p.join(appDocDir.path, 'aura_memories'));
      if (!await memoriesDir.exists()) {
        await memoriesDir.create(recursive: true);
      }

      final extension = p.extension(pickedFile.path).isNotEmpty ? p.extension(pickedFile.path) : '.jpg';
      final fileName = 'memory_photo_${DateTime.now().millisecondsSinceEpoch}$extension';
      final targetPath = p.join(memoriesDir.path, fileName);

      final bytes = await pickedFile.readAsBytes();
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(bytes);
      return targetPath;
    } catch (e) {
      debugPrint('Error saving file locally, returning original path: $e');
      return pickedFile.path;
    }
  }

  /// İzin Yönlendirme Diyaloğu
  static void _showPermissionDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primaryDark),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: ClayButton(
                  color: AppColors.clayCardSurface,
                  height: 44,
                  borderRadius: 14,
                  onPressed: () => Navigator.pop(ctx),
                  child: Center(
                    child: Text(
                      'common_cancel_opt'.tr(),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClayButton(
                  color: AppColors.primaryPink,
                  height: 44,
                  borderRadius: 14,
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: Center(
                    child: Text(
                      'media_perm_open_settings'.tr(),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.medicalAlertRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Güvenli Fotoğraf Widget'ı Üretici (Web Blob, Asset, Mobil File veya Fallback)
  static Widget buildPhotoWidget(
    String photoPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(18);

    Widget imageContent;

    if (photoPath.startsWith('assets/')) {
      imageContent = Image.asset(
        photoPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _buildPlaceholder(width, height),
      );
    } else if (kIsWeb ||
        photoPath.startsWith('blob:') ||
        photoPath.startsWith('http://') ||
        photoPath.startsWith('https://') ||
        photoPath.startsWith('data:')) {
      imageContent = Image.network(
        photoPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _buildPlaceholder(width, height),
      );
    } else if (kIsWeb) {
      imageContent = _buildPlaceholder(width, height);
    } else {
      bool fileExists = false;
      try {
        final file = File(photoPath);
        fileExists = file.existsSync();
      } catch (_) {
        fileExists = false;
      }

      if (fileExists) {
        imageContent = Image.file(
          File(photoPath) as dynamic,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildPlaceholder(width, height),
        );
      } else {
        imageContent = _buildPlaceholder(width, height);
      }
    }

    return ClipRRect(
      borderRadius: radius,
      child: imageContent,
    );
  }

  static Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3E8FF),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_rounded, color: Color(0xFFE899AE), size: 36),
            SizedBox(height: 4),
            Text(
              'Ultrason & Anı Fotoğrafı',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7A6E78)),
            ),
          ],
        ),
      ),
    );
  }
}
