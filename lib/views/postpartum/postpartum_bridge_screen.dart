import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../models/profile_model.dart';

/// Aura Pregnancy - "4. Trimester: Altın 40 Gün" Lohusa İyileşme Köprüsü
class PostpartumBridgeScreen extends StatefulWidget {
  final ProfileModel? profile;

  const PostpartumBridgeScreen({super.key, this.profile});

  static Future<void> show(BuildContext context, {ProfileModel? profile}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostpartumBridgeScreen(profile: profile),
      ),
    );
  }

  @override
  State<PostpartumBridgeScreen> createState() => _PostpartumBridgeScreenState();
}

class _PostpartumBridgeScreenState extends State<PostpartumBridgeScreen> {
  int _waterGlasses = 4;
  bool _ironTaken = true;
  int _selectedMoodIndex = 2; // 0: Zorlanıyorum, 1: Hassasım, 2: Huzurluyum, 3: Harikayım

  final List<String> _moods = [
    'Zorlanıyorum 🌧️',
    'Hassasım (Baby Blues) 🥺',
    'Huzurluyum 🌸',
    'Çok İyiyim ☀️',
  ];

  @override
  Widget build(BuildContext context) {
    final momName = widget.profile?.momName ?? 'Sevgili Anne';
    final babyName = widget.profile?.babyDisplayName ?? 'Bebeğiniz';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Aura 4. Trimester: Altın 40 Gün',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Şefkatli Karşılama Kartı
              ClayCard(
                color: AppColors.clayPeach,
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🕊️', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tebrikler $momName!',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              Text(
                                '$babyName dünyaya geldi. Şimdi sıra senin şefkatle iyileşmende.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '💡 "İlk 40 günde ağlamaklı hissetmen (Baby Blues) tamamen hormonların sıfırlanmasından kaynaklanıyor. Bu çok doğal, geçici ve sen muazzam bir annesin."',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Günlük Lohusa Duygu Durumu Check-in
              Text(
                'Bugün Kendini Nasıl Hissediyorsun?',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_moods.length, (index) {
                  final isSelected = _selectedMoodIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedMoodIndex = index);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryPink : AppColors.clayCardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryPink : Colors.white,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _moods[index].split(' ')[1],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Su & İlaç Takibi (Lohusa Hidrasyonu)
              ClayCard(
                color: AppColors.clayCardSurface,
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💧', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Süt Üretimi & Hidrasyon',
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_waterGlasses Bardak (2.5L)',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.waterBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.waterBlue),
                          onPressed: () {
                            if (_waterGlasses > 0) {
                              HapticFeedback.selectionClick();
                              setState(() => _waterGlasses--);
                            }
                          },
                        ),
                        Text(
                          '$_waterGlasses / 10 Bardak',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.waterBlue),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _waterGlasses++);
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 0.8),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _ironTaken = !_ironTaken);
                      },
                      child: Row(
                        children: [
                          Icon(
                            _ironTaken ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: _ironTaken ? AppColors.successGreen : AppColors.textMuted,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Günlük Demir & Multivitamin Takviyesi',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                Text(
                                  'Lohusalık toparlanması ve kan yapımı için kritik',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Emzirme ve Göğüs Ucu Bakım Rehberi
              ClayCard(
                color: AppColors.clayRose,
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🤱', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Göğüs Ucu Rahatlatma İpuçları',
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Her emzirme sonrası bir damla anne sütünü göğüs ucuna sürerek doğal iyileşmeyi başlatın.\n• Saf Lanolin kremini emzirmeden hemen sonra uygulayabilirsiniz (temizlemeye gerek yoktur).\n• Bebeğin sadece meme ucunu değil, areolanın (kahverengi alan) çoğunu kavramasını sağlayın.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Pelvik Taban ve Nazik Toparlanma
              ClayCard(
                color: AppColors.clayMint,
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🧘‍♀️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Pelvik Taban & Nazik İyileşme',
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• İlk 2 hafta ağır kaldırmaktan ve ani çömelmelerden kaçının.\n• Yatarak günde 3 set 5 kez hafif Kegel kasması kan dolaşımını hızlandırır.\n• Loşi (doğum sonrası akıntı) rengi kırmızıdan sarı-beyaza doğru dönecektir, aşırı pıhtılı kanamalarda hemen hekiminizi arayın.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 84),
            ],
          ),
        ),
      ),
    );
  }
}
