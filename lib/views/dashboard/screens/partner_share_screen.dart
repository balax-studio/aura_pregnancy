import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/profile_model.dart';

/// Aura Pregnancy - Tam Ekran Eş / Partner Paylaşım Kapsülü
class PartnerShareScreen extends StatefulWidget {
  final ProfileModel? profile;

  const PartnerShareScreen({super.key, this.profile});

  static Future<void> open(BuildContext context, {ProfileModel? profile}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PartnerShareScreen(profile: profile)),
    );
  }

  @override
  State<PartnerShareScreen> createState() => _PartnerShareScreenState();
}

class _PartnerShareScreenState extends State<PartnerShareScreen> {
  int _selectedCardIndex = 0;
  final TextEditingController _customNoteController = TextEditingController();

  @override
  void dispose() {
    _customNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final mom = p?.momName ?? 'Annemiz';
    final partner = p?.partnerName ?? 'Babamız';
    final baby = p?.babyDisplayName ?? 'Bebeğimiz';
    final week = p?.currentWeek ?? 20;

    final cards = [
      {
        'title': 'Bebekten Babaya Mektup 💌',
        'message': 'Babacığım ($partner) selam! Bugün $week. haftamızdayız. Kulaklarım artık senin sesini tanıyor. Anneme ($mom) sıcacık sarılmanı ve karnımı sevmeni bekliyorum! 💕',
        'emoji': '👶',
        'accent': AppColors.clayRose,
      },
      {
        'title': 'Bugün Anneye Nasıl Destek Olabilirsin? 🌸',
        'message': 'Günün Baba Tavsiyesi: Sevgili $partner, $mom bugün hormonlar ve $week. haftanın ağırlığıyla biraz yorulmuş olabilir. Ona ılık bir ayak masajı yapmak veya akşam yemeğini hazırlamak harika bir sürpriz olur! ☕',
        'emoji': '💆‍♀️',
        'accent': AppColors.clayPeach,
      },
      {
        'title': 'Günün Minik Aşermesi 🍓',
        'message': 'Babası ($partner), $baby bugün lezzetli bir şeyler istiyor gibi! Annemizin ($mom) canı tatlı bir meyve çekiyor, eve gelirken sürpriz yapmaya ne dersin? 🍇',
        'emoji': '✨',
        'accent': AppColors.clayMint,
      },
    ];

    final currentCard = cards[_selectedCardIndex];
    final defaultMessage = currentCard['message'] as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    _buildTemplateSelector(cards),
                    const SizedBox(height: 18),
                    _buildPreviewCard(currentCard),
                    const SizedBox(height: 20),
                    _buildShareButton(defaultMessage),
                    const SizedBox(height: 84),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partner Paylaşım Kapsülü',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'WhatsApp & Mesajlar İçin Romantik Kartlar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.clayRose,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('💌', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector(List<Map<String, dynamic>> cards) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(cards.length, (index) {
          final c = cards[index];
          final isSelected = index == _selectedCardIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCardIndex = index);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryPink : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(c['emoji'] as String, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      index == 0 ? 'Bebekten Mektup' : (index == 1 ? 'Anneye Destek' : 'Minik Aşerme'),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> card) {
    return ClayCard(
      color: card['accent'] as Color,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(card['emoji'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card['title'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              card['message'] as String,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.primaryDark,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '✨ Aura Pregnancy ile sevgiyle hazırlandı',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Text('💕', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(String message) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Clipboard.setData(ClipboardData(text: message));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Kart metni kopyalandı! Eşinize gönderebilirsiniz: "$message"',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
              backgroundColor: AppColors.primaryPink,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Mesajı Kopyala & WhatsApp\'a Yapıştır',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
