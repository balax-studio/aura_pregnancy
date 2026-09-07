import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';

/// Aura Pregnancy - 6 Evreli Gerçekçi Rahim İçi (In-Utero) Fetus Fotoğrafı ve Canlı Animasyon
class RealWombFetusWidget extends StatefulWidget {
  final int currentWeek;
  final int currentDay; // 1-7
  final String babyName;
  final String eddDate;
  final VoidCallback? onTap;

  const RealWombFetusWidget({
    super.key,
    required this.currentWeek,
    this.currentDay = 3,
    this.babyName = 'Bebeğimiz',
    this.eddDate = '2026-10-15',
    this.onTap,
  });

  @override
  State<RealWombFetusWidget> createState() => _RealWombFetusWidgetState();
}

class _RealWombFetusWidgetState extends State<RealWombFetusWidget>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _heartbeatController;

  @override
  void initState() {
    super.initState();

    // 1. Organik Fetal Solunum & Süzülme (3.8 saniye)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    // 2. Canlı Kalp Atışı Nabzı (140-160 BPM ritmi)
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  int _getStageForWeek(int week) {
    if (week <= 6) return 1;  // 1-6. Hafta: İlk Kalp Atımı & Erken Embriyo
    if (week <= 9) return 2;  // 7-9. Hafta: 8. Hafta Embriyo
    if (week <= 13) return 3; // 10-13. Hafta: 1. Trimester Fetus & NT
    if (week <= 17) return 4; // 14-17. Hafta: 15-16. Hafta Başparmak Emme
    if (week <= 21) return 5; // 18-21. Hafta: 2. Trimester Fetus & İlk Tekmeler
    if (week <= 25) return 6; // 22-25. Hafta: 2. Trimester Morfoloji & Kordon
    if (week <= 29) return 7; // 26-29. Hafta: Göz Kapaklarının Açılması & Ses Duyumu
    if (week <= 33) return 8; // 30-33. Hafta: Tombul Yanaklar & REM Rüyası
    if (week <= 36) return 9; // 34-36. Hafta: 3. Trimester Fetal Büyüme
    return 10;                // 37-40. Hafta: Doğuma Hazır Bebek
  }

  String _getHeartRateRange(int week) {
    if (week <= 6) {
      return '100 - 125 bpm';
    } else if (week <= 9) {
      return '140 - 170 bpm';
    } else if (week <= 13) {
      return '150 - 170 bpm';
    } else if (week <= 21) {
      return '135 - 160 bpm';
    } else if (week <= 29) {
      return '130 - 155 bpm';
    } else if (week <= 33) {
      return '125 - 150 bpm';
    } else {
      return '120 - 145 bpm';
    }
  }

  String _getStageTitle(int week) {
    if (week <= 6) return '1. Evre: Erken Embriyo & Kalp Tüpü (5-6. Hafta)';
    if (week <= 9) return '2. Evre: Organ Taslakları & Embriyo (8. Hafta)';
    if (week <= 13) return '3. Evre: 1. Trimester Fetus & Yüz Hatları (12. Hafta)';
    if (week <= 17) return '4. Evre: Parmak Emme & Refleksler (16. Hafta)';
    if (week <= 21) return '5. Evre: 2. Trimester Fetus & İlk Tekmeler (19. Hafta)';
    if (week <= 25) return '6. Evre: 2. Trimester Morfoloji & Kordon (24. Hafta)';
    if (week <= 29) return '7. Evre: Göz Kapaklarının Açılışı & İşitme (27. Hafta)';
    if (week <= 33) return '8. Evre: Tombul Yanaklar & REM Uykusu (32. Hafta)';
    if (week <= 36) return '9. Evre: 3. Trimester Fetal Büyüme (35. Hafta)';
    return '10. Evre: Doğuma Hazır Olgun Bebek (38-40. Hafta)';
  }

  void _showHeartRateInfoDialog(BuildContext context, String heartRateRange) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: ClayTheme.clayDecoration(
            color: Colors.white,
            borderRadius: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.clayRose,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 28),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Fetal Kalp Hızı (BPM) Bilgisi',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.clayPeach,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.speed_rounded, size: 14, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Text(
                      'Tahmini Aralık: $heartRateRange',
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Belirtilen $heartRateRange fetal kalp atım aralığı, gebeliğinizin bu haftası için klinik literatürdeki genel ortalama ve yaklaşık referans değerleridir.\n\nBebeğinizin uyku hali, hareketliliği veya günün farklı saatlerinde bu ritim doğal olarak değişkenlik gösterebilir. Sizin ve bebeğiniz için en ideal ve doğru değerlendirmeyi lütfen kendi kadın doğum hekiminize danışınız.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              ClayButton(
                color: AppColors.primaryPink,
                height: 44,
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                onPressed: () => Navigator.pop(ctx),
                child: Center(
                  child: Text(
                    'Anladım',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final week = widget.currentWeek;
    final stage = _getStageForWeek(week);
    final heartRateRange = _getHeartRateRange(week);
    final stageTitle = _getStageTitle(week);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF231826),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: 270,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Üretilen Gerçekçi In-Utero Fotoğrafı (Canlı Solunum Hareketi ile)
              AnimatedBuilder(
                animation: _breatheController,
                builder: (context, child) {
                  final scale = 1.0 + (sin(_breatheController.value * pi) * 0.035);
                  final offsetY = sin(_breatheController.value * pi) * 4.0;

                  return Transform.translate(
                    offset: Offset(0, offsetY),
                    child: Transform.scale(
                      scale: scale,
                      child: Image.asset(
                        'assets/images/womb_stage$stage.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) {
                          // Fallback
                          return Container(
                            color: AppColors.deepWombPlum,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.favorite_rounded, color: AppColors.fetalHeartPink, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    stageTitle,
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              // 2. Hafif Ferah Işık Filtresi (Karartma kaldırıldı)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),

              // 3. Canlı Fetal Kalp Atışı Rozeti & Bilgi (i) Butonu
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _showHeartRateInfoDialog(context, heartRateRange),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.fetalHeartPink.withValues(alpha: 0.8), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.fetalHeartPink.withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _heartbeatController,
                          builder: (context, child) {
                            final scale = 0.92 + (_heartbeatController.value * 0.16);
                            return Transform.scale(
                              scale: scale,
                              child: const Icon(Icons.favorite_rounded, color: AppColors.fetalHeartPink, size: 14),
                            );
                          },
                        ),
                        const SizedBox(width: 5),
                        Text(
                          heartRateRange,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
