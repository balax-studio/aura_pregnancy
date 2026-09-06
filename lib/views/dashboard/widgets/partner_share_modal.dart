import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/profile_model.dart';

/// Aura Pregnancy - Romantik Eş / Partner Paylaşım Kapsülü
class PartnerShareModal extends StatefulWidget {
  final ProfileModel? profile;

  const PartnerShareModal({super.key, this.profile});

  static Future<void> show(BuildContext context, {ProfileModel? profile}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartnerShareModal(profile: profile),
    );
  }

  @override
  State<PartnerShareModal> createState() => _PartnerShareModalState();
}

class _PartnerShareModalState extends State<PartnerShareModal> {
  int _selectedCardIndex = 0;

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

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.clayRose,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('💌', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eş / Partner Paylaşım Kartı',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'WhatsApp & Instagram İçin Romantik Kart',
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
          ),
          const SizedBox(height: 16),

          // Şablon Seçici
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(cards.length, (index) {
                final c = cards[index];
                final isSelected = index == _selectedCardIndex;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCardIndex = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryPink : AppColors.clayCardSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${c['emoji']} Şablon ${index + 1}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Görsel Kart Önizlemesi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClayCard(
                color: currentCard['accent'] as Color,
                borderRadius: 24,
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentCard['emoji'] as String,
                      style: const TextStyle(fontSize: 42),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentCard['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentCard['message'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aura Pregnancy 🌟 $week. Hafta',
                      style: GoogleFonts.jetBrainsMono(
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
          const SizedBox(height: 16),

          // Paylaşım Aksiyon Butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Clipboard.setData(ClipboardData(text: currentCard['message'] as String));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Metin panoya kopyalandı! WhatsApp\'a yapıştırabilirsiniz.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12),
                          ),
                          backgroundColor: AppColors.primaryPink,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: ClayCard(
                      color: AppColors.primaryPink,
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Mesajı Kopyala & Gönder',
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
