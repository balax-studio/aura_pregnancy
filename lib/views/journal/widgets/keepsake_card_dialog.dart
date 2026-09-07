import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) '../../../services/io_stubs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/profile_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/media_service.dart';
import '../../weekly_panel/widgets/ad_reward_dialog.dart';

/// Aura Pregnancy - Kişiye Özel Doğum Öncesi Hatıra Kartı Stüdyosu
/// Anne adı, bebek adı, gebelik haftası ve ultrason silüetini zarif bir hatıra kartında birleştirir.
class KeepsakeCardDialog extends StatefulWidget {
  final String? initialUltrasoundPath;

  const KeepsakeCardDialog({
    super.key,
    this.initialUltrasoundPath,
  });

  static Future<void> show(BuildContext context, {String? initialUltrasoundPath}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => KeepsakeCardDialog(initialUltrasoundPath: initialUltrasoundPath),
    );
  }

  @override
  State<KeepsakeCardDialog> createState() => _KeepsakeCardDialogState();
}

class _KeepsakeCardDialogState extends State<KeepsakeCardDialog> {
  final GlobalKey _artboardKey = GlobalKey();
  late String _photoPath;
  ProfileModel? _profile;
  bool _isUnlocked = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _photoPath = widget.initialUltrasoundPath ?? 'assets/images/sample_ultrasound.png';
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prof = await DatabaseHelper.instance.getProfile();
      if (mounted) {
        setState(() {
          _profile = prof;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile in KeepsakeCardDialog: $e');
    }
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
      title: 'keepsake_card_title'.tr(),
      subtitle: 'keepsake_card_cta'.tr(),
      unlockTargetName: 'keepsake_card',
      onRewardEarned: () {
        if (!mounted) return;
        setState(() {
          _isUnlocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('keepsake_card_success'.tr())),
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
      bool isSuccess = false;
      final boundary = _artboardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          isSuccess = await MediaService.instance.saveImageToGallery(
            imageBytes: pngBytes,
            fileNamePrefix: 'Aura_Hatira_Karti',
          );
        }
      }
      if (mounted) {
        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('keepsake_card_saved'.tr())),
                ],
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Görsel kaydedilemedi. Lütfen depolama ve galeri izinlerini kontrol ediniz.')),
                ],
              ),
              backgroundColor: AppColors.medicalAlertRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving keepsake card: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('media_error_save'.tr(args: [e.toString()]))),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildUltrasoundThumbnail() {
    if (_photoPath.startsWith('assets/')) {
      return Image.asset(
        _photoPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/sample_ultrasound.png',
          fit: BoxFit.cover,
        ),
      );
    } else if (kIsWeb) {
      return Image.asset(
        'assets/images/sample_ultrasound.png',
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(_photoPath) as dynamic,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/sample_ultrasound.png',
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyName = _profile?.babyName?.isNotEmpty == true ? _profile!.babyName! : 'Minik Mucizemiz';
    final momName = _profile?.momName?.isNotEmpty == true ? _profile!.momName! : 'Anne Adayı';
    final week = _profile?.currentWeek ?? 20;
    final dueDate = _profile?.dueDate ?? '2026';
    String formattedDueDate = dueDate;
    if (dueDate.contains('-')) {
      final parts = dueDate.split('-');
      if (parts.length == 3) {
        formattedDueDate = '${parts[2]}.${parts[1]}.${parts[0]}';
      }
    }

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
              // Üst Başlık Barı
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.clayPeach,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.card_giftcard_rounded, color: AppColors.primaryPink, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'keepsake_card_title'.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'keepsake_card_badge'.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.keepsakePurple,
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

              // Şefkatli Açıklama
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.keepsakePurpleBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.keepsakePurpleBorder.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.keepsakePurple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'keepsake_card_desc'.tr(),
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

              // Hatıra Kartı Artboard'u (RepaintBoundary)
              Center(
                child: RepaintBoundary(
                  key: _artboardKey,
                  child: Container(
                    width: 290,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGradientStart, // Krem kağıt rengi
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.clayPeach, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Kart Başlık Rozeti
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.clayRose,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.favorite_rounded, size: 11, color: AppColors.primaryPink),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AURA HATIRA KARTI',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Bebek Adı ve Hafta
                            Text(
                              babyName,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$week. Gebelik Haftası • Tahmini Doğum: $formattedDueDate',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Oval Ultrason Silüet Çerçevesi
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _buildUltrasoundThumbnail(),
                            ),
                            const SizedBox(height: 14),

                            // Anne Notu
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Sevgi ve heyecanla bekliyoruz...',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Alt İthaf
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Anne: $momName',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateTime.now().toLocal().toString().split(' ')[0],
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Kilitli Durum Kaplaması (Reklam İzlenmeden Önce)
                        if (!_isUnlocked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_rounded, color: AppColors.keepsakePurple, size: 28),
                                        const SizedBox(height: 6),
                                        Text(
                                          'keepsake_card_badge'.tr(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'keepsake_card_btn'.tr(),
                                          style: GoogleFonts.quicksand(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.keepsakePurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fotoğraf Değiştir
              Center(
                child: ClayButton(
                  color: AppColors.clayCardSurface,
                  height: 38,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: _pickNewPhoto,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_photo_alternate_rounded, size: 16, color: AppColors.lavenderPurple),
                      const SizedBox(width: 6),
                      Text(
                        'studio_change_photo'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Eylem Butonları
              if (!_isUnlocked)
                ClayButton(
                  color: AppColors.lavenderPurple,
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
                          'keepsake_card_btn'.tr(),
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
                            'keepsake_card_save_btn'.tr(),
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
