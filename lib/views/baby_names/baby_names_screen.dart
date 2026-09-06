import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/baby_names_data.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../models/baby_name_model.dart';
import '../../models/profile_model.dart';
import '../../services/database_helper.dart';
import '../weekly_panel/widgets/ad_reward_dialog.dart';
import 'widgets/baby_name_card.dart';

/// Aura Pregnancy - Bebek İsim Önerileri & Favoriler Ekranı
class BabyNamesScreen extends StatefulWidget {
  const BabyNamesScreen({super.key});

  @override
  State<BabyNamesScreen> createState() => _BabyNamesScreenState();
}

class _BabyNamesScreenState extends State<BabyNamesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProfileModel? _profile;
  String _activeGenderFilter = 'surprise';
  List<BabyNameModel> _daily5Names = [];
  List<BabyNameModel> _favoriteNames = [];
  List<BabyNameModel> _allFilteredNames = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
    DatabaseHelper.appDataRevision.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) {
      _loadFavorites();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    DatabaseHelper.appDataRevision.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _profile = await DatabaseHelper.instance.getProfile();
      _activeGenderFilter = _profile?.babyGender ?? 'surprise';
      _favoriteNames = await DatabaseHelper.instance.getFavoriteNames();
      _generateDaily5();
      _filterAllNames('');
    } catch (e) {
      debugPrint('BabyNamesScreen load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFavorites() async {
    final favs = await DatabaseHelper.instance.getFavoriteNames();
    if (mounted) {
      setState(() {
        _favoriteNames = favs;
      });
    }
  }

  void _generateDaily5() {
    _daily5Names = BabyNamesData.pick5DailyNames(
      gender: _activeGenderFilter,
    );
  }

  void _filterAllNames(String query) {
    final baseList = BabyNamesData.getNamesForGender(_activeGenderFilter);
    if (query.trim().isEmpty) {
      _allFilteredNames = List.from(baseList);
    } else {
      final q = query.trim().toLowerCase();
      _allFilteredNames = baseList.where((n) {
        return n.name.toLowerCase().contains(q) ||
            n.meaning.toLowerCase().contains(q) ||
            n.origin.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<void> _toggleFavorite(BabyNameModel name) async {
    await DatabaseHelper.instance.toggleFavoriteName(name);
    await _loadFavorites();
  }

  bool _isFavorite(String name) {
    return _favoriteNames.any((n) => n.name == name);
  }

  Future<void> _handleRefreshWithRewardAd() async {
    final rewardEarned = await AdRewardDialog.show(
      context: context,
      title: 'names_ad_reward_title'.tr(),
      subtitle: 'names_ad_reward_desc'.tr(),
      unlockTargetName: 'names_ad_reward_target'.tr(),
    );

    if (rewardEarned == true && mounted) {
      setState(() {
        final currentNames = _daily5Names.map((n) => n.name).toList();
        _daily5Names = BabyNamesData.pick5DailyNames(
          gender: _activeGenderFilter,
          excludeNames: currentNames,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'names_ad_reward_success'.tr(),
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'names_screen_title'.tr(),
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: ClayTheme.concaveDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: 18,
            ),
            child: TabBar(
              controller: _tabController,
              indicator: ClayTheme.clayButtonDecoration(
                color: Colors.white,
                borderRadius: 14,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w900),
              unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'names_tab_daily'.tr()),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('names_tab_favorites'.tr()),
                      if (_favoriteNames.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _favoriteNames.length.toString(),
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(text: 'names_tab_all'.tr()),
              ],
            ),
          ),
        ),
      ),
      body: AmbientBackground(
        child: Column(
          children: [
            // Cinsiyet Filtreleme Çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${'names_gender_filter_label'.tr()}: ',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildGenderChip('surprise', 'names_filter_all'.tr(), Icons.auto_awesome_rounded),
                  const SizedBox(width: 6),
                  _buildGenderChip('girl', 'names_gender_girl'.tr(), Icons.female_rounded),
                  const SizedBox(width: 6),
                  _buildGenderChip('boy', 'names_gender_boy'.tr(), Icons.male_rounded),
                ],
              ),
            ),

            // TabBarView İçerikleri
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. GÜNLÜK 5 ÖNERİ
                  _buildDailySuggestionsTab(),

                  // 2. FAVORİLERİM
                  _buildFavoritesTab(),

                  // 3. TÜM İSİMLER & ARAMA
                  _buildAllNamesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderChip(String gender, String label, IconData icon) {
    final isSelected = _activeGenderFilter == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeGenderFilter = gender;
          _generateDaily5();
          _filterAllNames(_searchController.text);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: isSelected
            ? ClayTheme.clayButtonDecoration(
                color: gender == 'girl'
                    ? AppColors.clayRose
                    : gender == 'boy'
                        ? AppColors.claySky
                        : AppColors.clayMint,
                borderRadius: 12,
              )
            : BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySuggestionsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Günün Bilgilendirme Rozeti
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: ClayTheme.clayDecoration(
            color: AppColors.clayPeach,
            borderRadius: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.stars_rounded, color: AppColors.secondaryPeach, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'names_daily_curated_title'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'names_daily_curated_desc'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Günün 5 İsmi
        ..._daily5Names.map(
          (item) => BabyNameCard(
            babyName: item,
            isFavorite: _isFavorite(item.name),
            onFavoriteToggle: _toggleFavorite,
          ),
        ),

        const SizedBox(height: 8),

        // Reklamlı Yenileme Butonu (Yeni 5 İsim Keşfet)
        ClayButton(
          color: AppColors.clayMint,
          height: 52,
          borderRadius: 18,
          onPressed: _handleRefreshWithRewardAd,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_display_rounded, color: Color(0xFF2E6135), size: 20),
              const SizedBox(width: 8),
              Text(
                'names_refresh_ad_btn'.tr(),
                style: GoogleFonts.nunito(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E6135),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteNames.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: ClayTheme.clayDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: 40,
                ),
                child: const Center(
                  child: Icon(Icons.favorite_border_rounded, color: AppColors.primaryPink, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'names_favorites_empty_title'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'names_favorites_empty_desc'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'names_favorites_count'.tr(args: [_favoriteNames.length.toString()]),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ..._favoriteNames.map(
          (item) => BabyNameCard(
            babyName: item,
            isFavorite: true,
            onFavoriteToggle: _toggleFavorite,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAllNamesTab() {
    return Column(
      children: [
        // Arama Çubuğu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            decoration: ClayTheme.concaveDecoration(
              color: Colors.white,
              borderRadius: 16,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _filterAllNames(val));
              },
              decoration: InputDecoration(
                hintText: 'names_search_hint'.tr(),
                hintStyle: GoogleFonts.quicksand(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryDark),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filterAllNames(''));
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ),

        // Liste
        Expanded(
          child: _allFilteredNames.isEmpty
              ? Center(
                  child: Text(
                    'names_no_results'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _allFilteredNames.length,
                  itemBuilder: (ctx, i) {
                    final item = _allFilteredNames[i];
                    return BabyNameCard(
                      babyName: item,
                      isFavorite: _isFavorite(item.name),
                      onFavoriteToggle: _toggleFavorite,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
