import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/safety_radar_data.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/safety_item_model.dart';
import '../../../services/database_helper.dart';

/// Aura Pregnancy - Tam Ekran "Yiyebilir Miyim? / Sürebilir Miyim?" Güvenlik Radarı
class SafetyRadarScreen extends StatefulWidget {
  final String? partnerName;
  final String? babyName;

  const SafetyRadarScreen({super.key, this.partnerName, this.babyName});

  static Future<void> open(BuildContext context, {String? partnerName, String? babyName}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SafetyRadarScreen(partnerName: partnerName, babyName: babyName),
      ),
    );
  }

  @override
  State<SafetyRadarScreen> createState() => _SafetyRadarScreenState();
}

class _SafetyRadarScreenState extends State<SafetyRadarScreen> {
  final TextEditingController _searchController = TextEditingController();
  SafetyCategory? _selectedCategory;
  SafetyLevel? _selectedLevel;
  Set<String> _favoriteIds = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favs = await DatabaseHelper.instance.getSafetyFavorites();
    if (mounted) {
      setState(() => _favoriteIds = favs);
    }
  }

  Future<void> _toggleFavorite(String itemId) async {
    HapticFeedback.selectionClick();
    await DatabaseHelper.instance.toggleSafetyFavorite(itemId);
    await _loadFavorites();
  }

  void _shareCravingWithPartner(SafetyItem item) {
    HapticFeedback.mediumImpact();
    final isEn = context.locale.languageCode == 'en';
    final partner = widget.partnerName ?? (isEn ? 'Dad' : 'Babası');
    final baby = widget.babyName ?? (isEn ? 'Our little one' : 'Minik misafirimiz');
    final itemTitle = item.localizedTitle(context.locale.languageCode);
    final itemSummary = item.localizedSummary(context.locale.languageCode);
    final message = 'safety_craving_share_template'.tr(args: [partner, baby, itemTitle, itemSummary]);

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'safety_card_partner_toast'.tr(args: [message]),
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        backgroundColor: AppColors.primaryPink,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = SafetyRadarData.search(
      _query,
      category: _selectedCategory,
      level: _selectedLevel,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: _buildSearchBar(),
            ),
            _buildFilterChips(),
            const SizedBox(height: 10),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.clayLavender.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 42,
                              color: AppColors.primaryPink,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'safety_empty_title'.tr(),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'safety_empty_sub'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 84),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      itemCount: searchResults.length + 1,
                      itemBuilder: (context, index) {
                        if (index == searchResults.length) {
                          return const SizedBox(height: 84);
                        }
                        final item = searchResults[index];
                        final isFav = _favoriteIds.contains(item.id);
                        return _buildSafetyCard(item, isFav);
                      },
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
                  'safety_radar_appbar_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'safety_radar_appbar_sub'.tr(),
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
              color: AppColors.clayMint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.clinicalGreen.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.radar_rounded, size: 22, color: AppColors.clinicalGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _query = val),
      decoration: InputDecoration(
        hintText: 'safety_radar_search_hint'.tr(),
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPink),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip('safety_filter_all'.tr(), _selectedCategory == null && _selectedLevel == null, () {
            setState(() {
              _selectedCategory = null;
              _selectedLevel = null;
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip('🍽️ ${'safety_filter_food'.tr()}', _selectedCategory == SafetyCategory.food, () {
            setState(() => _selectedCategory = _selectedCategory == SafetyCategory.food ? null : SafetyCategory.food);
          }),
          const SizedBox(width: 8),
          _buildFilterChip('🧴 ${'safety_filter_skincare'.tr()}', _selectedCategory == SafetyCategory.skincare, () {
            setState(() => _selectedCategory = _selectedCategory == SafetyCategory.skincare ? null : SafetyCategory.skincare);
          }),
          const SizedBox(width: 8),
          _buildFilterChip('🌿 ${'safety_filter_herb'.tr()}', _selectedCategory == SafetyCategory.herb, () {
            setState(() => _selectedCategory = _selectedCategory == SafetyCategory.herb ? null : SafetyCategory.herb);
          }),
          const SizedBox(width: 8),
          _buildFilterChip('safety_level_safe_badge'.tr(), _selectedLevel == SafetyLevel.safe, () {
            setState(() => _selectedLevel = _selectedLevel == SafetyLevel.safe ? null : SafetyLevel.safe);
          }),
          const SizedBox(width: 8),
          _buildFilterChip('safety_level_unsafe_badge'.tr(), _selectedLevel == SafetyLevel.unsafe, () {
            setState(() => _selectedLevel = _selectedLevel == SafetyLevel.unsafe ? null : SafetyLevel.unsafe);
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyCard(SafetyItem item, bool isFav) {
    Color badgeColor;
    String badgeText;
    Color cardColor;
    final isEn = context.locale.languageCode == 'en';

    switch (item.level) {
      case SafetyLevel.safe:
        badgeColor = AppColors.successGreen;
        badgeText = isEn ? 'SAFE' : 'GÜVENLİ';
        cardColor = AppColors.clayMint;
        break;
      case SafetyLevel.moderate:
        badgeColor = AppColors.amberCaution;
        badgeText = isEn ? 'CAUTION' : 'ÖLÇÜLÜ / DİKKAT';
        cardColor = AppColors.clayPeach;
        break;
      case SafetyLevel.unsafe:
        badgeColor = AppColors.medicalAlertRed;
        badgeText = isEn ? 'AVOID' : 'SAKINCALI';
        cardColor = AppColors.clayRose;
        break;
    }

    final itemTitle = item.localizedTitle(context.locale.languageCode);
    final itemSummary = item.localizedSummary(context.locale.languageCode);
    final itemReason = item.localizedMedicalReason(context.locale.languageCode);
    final itemAlternative = item.localizedAlternative(context.locale.languageCode);

    return ClayCard(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category == SafetyCategory.food
                          ? 'safety_filter_food'.tr()
                          : (item.category == SafetyCategory.skincare ? 'safety_filter_skincare'.tr() : 'safety_filter_herb'.tr()),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isFav ? AppColors.primaryPink : AppColors.textMuted,
                  size: 22,
                ),
                onPressed: () => _toggleFavorite(item.id),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              itemSummary,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.primaryDark,
                height: 1.35,
              ),
            ),
          ),
          if (itemReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medical_services_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      itemReason,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (itemAlternative != null && itemAlternative.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppColors.successGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${'safety_card_alternative'.tr()}: $itemAlternative',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClayButton(
                onPressed: () => _shareCravingWithPartner(item),
                color: AppColors.clayCardSurface,
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded, size: 14, color: AppColors.primaryPink),
                    const SizedBox(width: 6),
                    Text(
                      'safety_card_partner_share_btn'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
