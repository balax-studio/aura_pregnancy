import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) '../../../services/io_stubs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../services/media_service.dart';
import '../../weekly_panel/widgets/ad_reward_dialog.dart';

/// Aura Pregnancy - Masalsı Suluboya Bebek Portresi Stüdyosu
/// Ultrason görüntüsünü doğrudan telefonda pastel suluboya sanat tablosuna dönüştürür.
class WatercolorPortraitDialog extends StatefulWidget {
  final String? initialUltrasoundPath;

  const WatercolorPortraitDialog({
    super.key,
    this.initialUltrasoundPath,
  });

  static Future<void> show(BuildContext context, {String? initialUltrasoundPath}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => WatercolorPortraitDialog(initialUltrasoundPath: initialUltrasoundPath),
    );
  }

  @override
  State<WatercolorPortraitDialog> createState() => _WatercolorPortraitDialogState();
}

class _WatercolorPortraitDialogState extends State<WatercolorPortraitDialog> {
  final GlobalKey _artboardKey = GlobalKey();
  late String _photoPath;
  bool _isUnlocked = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _photoPath = widget.initialUltrasoundPath ?? 'assets/images/sample_ultrasound.png';
  }

  Future<void> _pickNewPhoto() async {
    final path = await MediaService.instance.showPhotoPickerDialog(context);
    if (path != null && path.isNotEmpty && mounted) {
      setState(() {
        _photoPath = path;
      });
    }
  }

  void _unlockWithReward() {
    AdRewardDialog.show(
      context: context,
      title: 'portrait_watercolor_title'.tr(),
      subtitle: 'portrait_watercolor_cta'.tr(),
      unlockTargetName: 'watercolor_portrait',
      onRewardEarned: () {
        if (!mounted) return;
        setState(() {
          _isUnlocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('portrait_watercolor_success'.tr())),
              ],
            ),
            backgroundColor: AppColors.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  Future<void> _saveArtboard() async {
    setState(() => _isSaving = true);
    try {
      final boundary = _artboardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          String? dirPath;
          if (!kIsWeb && Platform.isAndroid) {
            final publicDownload = Directory('/storage/emulated/0/Download');
            if (publicDownload.existsSync()) {
              dirPath = publicDownload.path;
            }
          }
          if (dirPath == null) {
            final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
            dirPath = dir.path;
          }
          final file = File('$dirPath/Aura_Ultrason_Portresi_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(pngBytes);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('portrait_watercolor_saved'.tr())),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving artboard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('media_error_select'.tr(args: [e.toString()]))),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildUltrasoundImage({bool applyFilter = false}) {
    Widget rawImage;
    if (_photoPath.startsWith('assets/')) {
      rawImage = Image.asset(
        _photoPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/sample_ultrasound.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      rawImage = Image.file(
        File(_photoPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/sample_ultrasound.png',
          fit: BoxFit.cover,
        ),
      );
    }

    if (!applyFilter) {
      return rawImage;
    }

    // Masalsı Suluboya & Pastel Efekt Katmanları
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Temel Görüntü
        rawImage,
        // 2. Sıcak Pastel Ten & Suluboya Renk Geçişi
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFE0D6).withValues(alpha: 0.65),
                const Color(0xFFFDE8E4).withValues(alpha: 0.50),
                const Color(0xFFE8F0FE).withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
        // 3. Masalsı Yumuşak Işık Efekti
        CustomPaint(
          painter: _WatercolorTexturePainter(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: ClayTheme.clayDecoration(
                      color: const Color(0xFFFEE6E0),
                      borderRadius: 14,
                    ),
                    child: const Icon(Icons.palette_rounded, color: AppColors.primaryPink, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'portrait_watercolor_title'.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'portrait_watercolor_badge'.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Şefkatli Açıklama Metni
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'portrait_watercolor_desc'.tr(),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kanvas / Artboard Alanı
              Center(
                child: RepaintBoundary(
                  key: _artboardKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280, maxHeight: 320),
                    child: Container(
                      width: 280,
                      height: 320,
                      decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEADFD8), width: 6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Portre Görseli
                        Positioned.fill(
                          child: _buildUltrasoundImage(applyFilter: _isUnlocked),
                        ),

                        // Kilitli Durum Kaplaması (Reklam İzlenmeden Önce)
                        if (!_isUnlocked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.60),
                              ),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: ClayTheme.clayDecoration(
                                      color: Colors.white,
                                      borderRadius: 18,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_rounded, color: AppColors.primaryPink, size: 28),
                                        const SizedBox(height: 6),
                                        Text(
                                          'portrait_watercolor_badge'.tr(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'portrait_watercolor_btn'.tr(),
                                          style: GoogleFonts.quicksand(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryPink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Alt Başlık Damgası (Açıldıktan sonra)
                        if (_isUnlocked)
                          Positioned(
                            bottom: 10,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.brush_rounded, size: 12, color: AppColors.primaryPink),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Aura • Ultrason Portresi',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
              const SizedBox(height: 16),

              // Fotoğraf Seç / Değiştir Butonu
              Center(
                child: TextButton.icon(
                  onPressed: _pickNewPhoto,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 16, color: AppColors.textSecondary),
                  label: Text(
                    'studio_change_photo'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Alt Eylem Butonları
              if (!_isUnlocked)
                ClayButton(
                  color: AppColors.primaryPink,
                  height: 52,
                  borderRadius: 16,
                  onPressed: _unlockWithReward,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'portrait_watercolor_btn'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ClayButton(
                  color: AppColors.clayPeach,
                  height: 52,
                  borderRadius: 16,
                  onPressed: _isSaving ? null : _saveArtboard,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSaving)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                        )
                      else ...[
                        const Icon(Icons.download_rounded, color: AppColors.primaryDark, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'portrait_watercolor_save_btn'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Suluboya ve Fırça Dokusu Çizicisi
class _WatercolorTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Yumuşak Köşe Vignette
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          Colors.transparent,
          const Color(0xFFFBE4DC).withValues(alpha: 0.35),
          const Color(0xFFE8D5C8).withValues(alpha: 0.20),
        ],
        stops: const [0.65, 0.90, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
