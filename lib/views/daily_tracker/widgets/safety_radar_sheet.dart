import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/safety_radar_data.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/safety_item_model.dart';
import '../../../services/database_helper.dart';

import '../screens/safety_radar_screen.dart';

/// Aura Pregnancy - "Yiyebilir Miyim? / Sürebilir Miyim?" Güvenlik Radarı
class SafetyRadarSheet extends StatefulWidget {
  final String? partnerName;
  final String? babyName;

  const SafetyRadarSheet({super.key, this.partnerName, this.babyName});

  static Future<void> show(BuildContext context, {String? partnerName, String? babyName}) {
    return SafetyRadarScreen.open(context, partnerName: partnerName, babyName: babyName);
  }

  @override
  State<SafetyRadarSheet> createState() => _SafetyRadarSheetState();
}

class _SafetyRadarSheetState extends State<SafetyRadarSheet> {
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
    final partner = widget.partnerName ?? 'Babası';
    final baby = widget.babyName ?? 'Minik misafirimiz';
    final message = 'Babası ($partner) selam! 🍓 $baby ile canımız fena halde "${item.title}" çekiyor! Güvenlik Radarı baktık; ${item.summary} 😋 Bize getirebilir misin?';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mesaj panoya kopyalandı! WhatsApp\'a yapıştırabilirsiniz: "$message"',
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
                    color: AppColors.clayMint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('🔍', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Güvenlik Radarı',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Yiyebilir Miyim? / Sürebilir Miyim?',
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
          const SizedBox(height: 14),

          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Örn: Çiğ köfte, ton balığı, retinol, adaçayı...',
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
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Kategori Filtre Çipleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('Tümü', _selectedCategory == null && _selectedLevel == null, () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedLevel = null;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('🍽️ Besinler', _selectedCategory == SafetyCategory.food, () {
                  setState(() => _selectedCategory = _selectedCategory == SafetyCategory.food ? null : SafetyCategory.food);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('🧴 Cilt Bakımı', _selectedCategory == SafetyCategory.skincare, () {
                  setState(() => _selectedCategory = _selectedCategory == SafetyCategory.skincare ? null : SafetyCategory.skincare);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('🌿 Bitki Çayları', _selectedCategory == SafetyCategory.herb, () {
                  setState(() => _selectedCategory = _selectedCategory == SafetyCategory.herb ? null : SafetyCategory.herb);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('🟢 Güvenli', _selectedLevel == SafetyLevel.safe, () {
                  setState(() => _selectedLevel = _selectedLevel == SafetyLevel.safe ? null : SafetyLevel.safe);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('🔴 Sakıncalı', _selectedLevel == SafetyLevel.unsafe, () {
                  setState(() => _selectedLevel = _selectedLevel == SafetyLevel.unsafe ? null : SafetyLevel.unsafe);
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sonuç Listesi
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔎', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          'Aradığınız öğe bulunamadı.',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Şüpheli her durumda hekiminize danışınız.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final item = searchResults[index];
                      final isFav = _favoriteIds.contains(item.id);
                      return _buildSafetyCard(item, isFav);
                    },
                  ),
          ),
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
          color: isSelected ? AppColors.primaryPink : AppColors.clayCardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
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
    Color levelColor;
    String levelBadge;

    switch (item.level) {
      case SafetyLevel.safe:
        levelColor = AppColors.successGreen;
        levelBadge = 'GÜVENLİ 🟢';
        break;
      case SafetyLevel.moderate:
        levelColor = AppColors.accentGold;
        levelBadge = 'ÖLÇÜLÜ 🟡';
        break;
      case SafetyLevel.unsafe:
        levelColor = AppColors.medicalAlertRed;
        levelBadge = 'SAKINCALI 🔴';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClayCard(
        color: AppColors.clayCardSurface,
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          levelBadge,
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: levelColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.primaryPink : AppColors.textMuted,
                    size: 22,
                  ),
                  onPressed: () => _toggleFavorite(item.id),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Özet
            Text(
              item.summary,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Tıbbi Gerekçe
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🩺 ', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Text(
                      item.medicalReason,
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

            // Alternatif Öneri Varsa
            if (item.alternativeSuggestion != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      'Güvenli Alternatif: ${item.alternativeSuggestion}',
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

            // "Aşeriyorum Babası!" Butonu
            if (item.category == SafetyCategory.food && item.level != SafetyLevel.unsafe) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _shareCravingWithPartner(item),
                  icon: const Icon(Icons.favorite_rounded, size: 14, color: AppColors.primaryPink),
                  label: Text(
                    'Aşeriyorum Babası! 🍓',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryPink.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
