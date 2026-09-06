import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/media_service.dart';

/// Büyütülmüş Fotoğraf İnceleme Diyaloğu (Lightbox)
class PhotoViewDialog extends StatelessWidget {
  final String photoPath;
  final String? title;

  const PhotoViewDialog({
    super.key,
    required this.photoPath,
    this.title,
  });

  static void show(BuildContext context, String photoPath, {String? title}) {
    showDialog(
      context: context,
      builder: (_) => PhotoViewDialog(photoPath: photoPath, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MediaService.buildPhotoWidget(
                    photoPath,
                    width: double.infinity,
                    height: 320,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌸', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'photo_memory_caption'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryPink,
                child: Icon(Icons.close_rounded, size: 18, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
