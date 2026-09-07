import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/baby_name_model.dart';

/// Aura Pregnancy - Claymorphic Bebek İsim Kartı
class BabyNameCard extends StatefulWidget {
  final BabyNameModel babyName;
  final bool isFavorite;
  final Future<void> Function(BabyNameModel) onFavoriteToggle;

  const BabyNameCard({
    super.key,
    required this.babyName,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<BabyNameCard> createState() => _BabyNameCardState();
}

class _BabyNameCardState extends State<BabyNameCard> {
  late bool _favState;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _favState = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant BabyNameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() => _favState = widget.isFavorite);
    }
  }

  Future<void> _handleFavorite() async {
    if (_isToggling) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isToggling = true;
      _favState = !_favState;
    });

    try {
      await widget.onFavoriteToggle(widget.babyName);
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  Color _getGenderColor() {
    switch (widget.babyName.gender) {
      case 'girl':
        return AppColors.clayRose;
      case 'boy':
        return AppColors.claySky;
      case 'unisex':
      default:
        return AppColors.clayCream;
    }
  }

  Color _getGenderAccent() {
    switch (widget.babyName.gender) {
      case 'girl':
        return AppColors.primaryPink;
      case 'boy':
        return AppColors.waterBlue;
      case 'unisex':
      default:
        return AppColors.accentGold;
    }
  }

  IconData _getGenderIcon() {
    switch (widget.babyName.gender) {
      case 'girl':
        return Icons.female_rounded;
      case 'boy':
        return Icons.male_rounded;
      case 'unisex':
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  String _getGenderLabel() {
    switch (widget.babyName.gender) {
      case 'girl':
        return 'names_gender_girl'.tr();
      case 'boy':
        return 'names_gender_boy'.tr();
      case 'unisex':
      default:
        return 'names_gender_unisex'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final genderColor = _getGenderColor();
    final genderAccent = _getGenderAccent();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: ClayTheme.clayDecoration(
        color: AppColors.clayCardSurface,
        borderRadius: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: İsim, Cinsiyet Rozeti, Köken Rozeti ve Favori Butonu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.babyName.name,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Cinsiyet Rozeti
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: ClayTheme.clayButtonDecoration(
                            color: genderColor,
                            borderRadius: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getGenderIcon(), size: 12, color: genderAccent),
                              const SizedBox(width: 4),
                              Text(
                                _getGenderLabel(),
                                style: GoogleFonts.nunito(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: genderAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Köken Bilgisi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${'names_origin_label'.tr()}: ${widget.babyName.origin}',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Favori Kalp Butonu
              GestureDetector(
                onTap: _handleFavorite,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 44,
                  height: 44,
                  decoration: ClayTheme.clayDecoration(
                    color: _favState ? AppColors.clayRose : Colors.white,
                    borderRadius: 14,
                    isPressed: _favState,
                  ),
                  child: Center(
                    child: Icon(
                      _favState ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _favState ? AppColors.primaryPink : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Anlamı
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.menu_book_rounded, size: 15, color: AppColors.secondaryPeach),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.babyName.meaning,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Karakter Analizi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: ClayTheme.concaveDecoration(
              color: Colors.white,
              borderRadius: 14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_alt_rounded, size: 16, color: AppColors.waterBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: '${'names_character_label'.tr()}: ',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                        ),
                        TextSpan(
                          text: widget.babyName.characteristics,
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kültürel / Şiirsel Not (Varsa)
          if (widget.babyName.culturalNote != null && widget.babyName.culturalNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.accentGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.babyName.culturalNote!,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
