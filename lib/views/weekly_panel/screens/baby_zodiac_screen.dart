import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/baby_zodiac_data.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/baby_zodiac_model.dart';
import '../../../models/profile_model.dart';

/// Aura Pregnancy - Bebek Burç, Mizaç ve Ebeveyn Uyum Detaylı Alt Sayfası
class BabyZodiacScreen extends StatefulWidget {
  final ProfileModel? profile;
  final String? initialSign;

  const BabyZodiacScreen({
    super.key,
    this.profile,
    this.initialSign,
  });

  static Future<void> open(BuildContext context, {ProfileModel? profile, String? initialSign}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BabyZodiacScreen(
          profile: profile,
          initialSign: initialSign,
        ),
      ),
    );
  }

  @override
  State<BabyZodiacScreen> createState() => _BabyZodiacScreenState();
}

class _BabyZodiacScreenState extends State<BabyZodiacScreen> {
  late String _selectedSign;
  String _selectedMomSign = 'Yengeç';
  late BabyZodiacModel _calculatedBabySign;

  @override
  void initState() {
    super.initState();
    if (widget.profile?.dueDate != null && widget.profile!.dueDate.isNotEmpty) {
      _calculatedBabySign = BabyZodiacData.calculateFromDueDateString(widget.profile!.dueDate);
    } else {
      _calculatedBabySign = BabyZodiacData.calculateFromDueDate(
        DateTime.now().add(const Duration(days: 90)),
      );
    }
    _selectedSign = widget.initialSign ?? _calculatedBabySign.signName;
  }

  String _getLocalizedSignName(String sign, String lang) {
    if (lang != 'en') return sign;
    const map = {
      'Koç': 'Aries',
      'Boğa': 'Taurus',
      'İkizler': 'Gemini',
      'Yengeç': 'Cancer',
      'Aslan': 'Leo',
      'Başak': 'Virgo',
      'Terazi': 'Libra',
      'Akrep': 'Scorpio',
      'Yay': 'Sagittarius',
      'Oğlak': 'Capricorn',
      'Kova': 'Aquarius',
      'Balık': 'Pisces',
    };
    return map[sign] ?? sign;
  }

  String _getLocalizedElement(String elem, String lang) {
    if (lang != 'en') return elem;
    const map = {
      'Ateş': 'Fire',
      'Toprak': 'Earth',
      'Hava': 'Air',
      'Su': 'Water',
    };
    return map[elem] ?? elem;
  }

  Color _getElementColor(String element) {
    switch (element) {
      case 'Ateş':
        return AppColors.primaryPink;
      case 'Toprak':
        return AppColors.successGreen;
      case 'Hava':
        return AppColors.waterBlue;
      case 'Su':
      default:
        return AppColors.lavenderPurple;
    }
  }

  Color _getElementSurfaceColor(String element) {
    switch (element) {
      case 'Ateş':
        return AppColors.clayRose;
      case 'Toprak':
        return AppColors.clayMint;
      case 'Hava':
        return AppColors.claySky;
      case 'Su':
      default:
        return AppColors.clayLavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final currentModel = BabyZodiacData.calculateFromDueDate(
      _getDateForSign(_selectedSign),
    );

    final compat = BabyZodiacData.calculateMotherBabyCompatibility(
      _selectedMomSign,
      currentModel.signName,
    );

    final isBabyOwnSign = currentModel.signName == _calculatedBabySign.signName;
    final localizedSignName = _getLocalizedSignName(currentModel.signName, lang);
    final localizedElement = _getLocalizedElement(currentModel.element, lang);
    final elementColor = _getElementColor(currentModel.element);
    final elementSurface = _getElementSurfaceColor(currentModel.element);

    final babyDisplayName = widget.profile?.babyDisplayName ?? 'Bebeğiniz';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            _buildZodiacSelector(lang),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // 1. Ana Burç Hero Kartı
                  _buildHeroCard(
                    currentModel: currentModel,
                    localizedSignName: localizedSignName,
                    localizedElement: localizedElement,
                    elementColor: elementColor,
                    elementSurface: elementSurface,
                    isBabyOwnSign: isBabyOwnSign,
                    babyDisplayName: babyDisplayName,
                  ),
                  const SizedBox(height: 16),

                  // 2. Bento Özet Kapsülleri (4'lü Grid)
                  _buildBentoGrid(currentModel, localizedElement, elementColor),
                  const SizedBox(height: 16),

                  // 3. Karakter ve Ruhsal Mizaç
                  _buildEditorialSection(
                    icon: Icons.psychology_rounded,
                    iconColor: AppColors.lavenderPurple,
                    title: 'zodiac_section_temperament'.tr(),
                    content: currentModel.temperament,
                    surfaceColor: AppColors.clayLavender,
                  ),
                  const SizedBox(height: 14),

                  // 4. Duyusal Keşif ve Oyun Eğilimleri
                  if (currentModel.sensoryPlay.isNotEmpty) ...[
                    _buildEditorialSection(
                      icon: Icons.toys_rounded,
                      iconColor: AppColors.secondaryPeach,
                      title: 'zodiac_section_sensory'.tr(),
                      content: currentModel.sensoryPlay,
                      surfaceColor: AppColors.clayPeach,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 5. Uyku Bioritmi & Sakinleştirme Ritüelleri
                  _buildEditorialSection(
                    icon: Icons.bedtime_rounded,
                    iconColor: AppColors.waterBlue,
                    title: 'zodiac_section_sleep'.tr(),
                    content: currentModel.sleepTendency,
                    surfaceColor: AppColors.claySky,
                  ),
                  const SizedBox(height: 14),

                  // 6. Duygusal İhtiyaçlar & Güvenli Bağlanma
                  _buildEditorialSection(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.primaryPink,
                    title: 'zodiac_section_emotional'.tr(),
                    content: currentModel.emotionalNeeds,
                    surfaceColor: AppColors.clayRose,
                  ),
                  const SizedBox(height: 14),

                  // 7. Ebeveynlik Sanatı ve Rehberlik
                  _buildEditorialSection(
                    icon: Icons.spa_rounded,
                    iconColor: AppColors.successGreen,
                    title: 'zodiac_section_parenting'.tr(),
                    content: currentModel.parentingAdvice,
                    surfaceColor: AppColors.clayMint,
                  ),
                  const SizedBox(height: 20),

                  // 8. Anne - Bebek Astrolojik Uyumu ve Sinerji Analizi
                  _buildCompatibilityModule(
                    compat: compat,
                    currentModel: currentModel,
                    lang: lang,
                  ),
                  const SizedBox(height: 84), // Anti-slop alt bar boşluğu
                ],
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
          ClayButton(
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.clayCardSurface,
            width: 44,
            height: 44,
            borderRadius: 16,
            padding: EdgeInsets.zero,
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'more_tool_zodiac_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'zodiac_appbar_subtitle'.tr(),
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
              color: AppColors.clayLavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.lavenderPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacSelector(String lang) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: BabyZodiacData.allZodiacNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sign = BabyZodiacData.allZodiacNames[index];
          final isSelected = sign == _selectedSign;
          final isBabySign = sign == _calculatedBabySign.signName;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedSign = sign);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryDark : (isBabySign ? AppColors.clayRose : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryDark
                      : (isBabySign ? AppColors.primaryPink.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.06)),
                  width: isSelected || isBabySign ? 1.4 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBabySign && !isSelected) ...[
                    const Icon(Icons.favorite_rounded, size: 12, color: AppColors.primaryPink),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _getLocalizedSignName(sign, lang),
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : (isBabySign ? AppColors.primaryPink : AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard({
    required BabyZodiacModel currentModel,
    required String localizedSignName,
    required String localizedElement,
    required Color elementColor,
    required Color elementSurface,
    required bool isBabyOwnSign,
    required String babyDisplayName,
  }) {
    return ClayCard(
      color: elementSurface,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: elementColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    currentModel.symbol,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBabyOwnSign)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$babyDisplayName Doğum Burcu',
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Text(
                      localizedSignName,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      '${currentModel.dateRangeStr} • $localizedElement Elementi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: elementColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            currentModel.headline,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              height: 1.35,
            ),
          ),
          if (currentModel.isCusp && currentModel.cuspNotice != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accentGold),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      currentModel.cuspNotice!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BabyZodiacModel model, String localizedElement, Color elementColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.diamond_rounded, size: 14, color: elementColor),
                    const SizedBox(width: 4),
                    Text(
                      'zodiac_gemstone'.tr(),
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  model.gemStone,
                  style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_rounded, size: 14, color: elementColor),
                    const SizedBox(width: 4),
                    Text(
                      'zodiac_colors'.tr(),
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  model.luckyColors.join(', '),
                  style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditorialSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Color surfaceColor,
  }) {
    return ClayCard(
      color: surfaceColor,
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDark.withValues(alpha: 0.88),
              height: 1.48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityModule({
    required Map<String, dynamic> compat,
    required BabyZodiacModel currentModel,
    required String lang,
  }) {
    final score = compat['score'] as int? ?? 90;

    return ClayCard(
      color: AppColors.clayPeach,
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'zodiac_compat_title'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      'zodiac_compat_sub'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '%$score Uyum',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Anne Burcu Seçici
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'zodiac_mom_sign_label'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedMomSign,
                  underline: const SizedBox(),
                  isDense: true,
                  items: BabyZodiacData.allZodiacNames.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(
                        _getLocalizedSignName(s, lang),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMomSign = val);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            compat['summary'] as String? ?? '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.key_rounded, size: 16, color: AppColors.secondaryPeach),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    compat['parentingKey'] as String? ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getDateForSign(String sign) {
    switch (sign) {
      case 'Koç':
        return DateTime(2026, 3, 25);
      case 'Boğa':
        return DateTime(2026, 4, 25);
      case 'İkizler':
        return DateTime(2026, 5, 25);
      case 'Yengeç':
        return DateTime(2026, 6, 25);
      case 'Aslan':
        return DateTime(2026, 7, 25);
      case 'Başak':
        return DateTime(2026, 8, 25);
      case 'Terazi':
        return DateTime(2026, 9, 25);
      case 'Akrep':
        return DateTime(2026, 10, 25);
      case 'Yay':
        return DateTime(2026, 11, 25);
      case 'Oğlak':
        return DateTime(2026, 12, 25);
      case 'Kova':
        return DateTime(2026, 1, 25);
      case 'Balık':
      default:
        return DateTime(2026, 2, 25);
    }
  }
}
