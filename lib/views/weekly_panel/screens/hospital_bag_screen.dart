import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/hospital_bag_item.dart';
import '../../../services/database_helper.dart';

/// Aura Pregnancy - Tam Ekran Akıllı Doğum Çantası & Hastane Hazırlık Ekranı
class HospitalBagScreen extends StatefulWidget {
  const HospitalBagScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HospitalBagScreen()),
    );
  }

  @override
  State<HospitalBagScreen> createState() => _HospitalBagScreenState();
}

class _HospitalBagScreenState extends State<HospitalBagScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _newItemController = TextEditingController();
  List<HospitalBagItem> _items = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = const [
    {'key': 'mom', 'titleKey': 'hospital_bag_tab_mom', 'emoji': '🌸', 'color': AppColors.clayRose},
    {'key': 'baby', 'titleKey': 'hospital_bag_tab_baby', 'emoji': '🍼', 'color': AppColors.clayMint},
    {'key': 'partner', 'titleKey': 'hospital_bag_tab_partner', 'emoji': '☕', 'color': AppColors.clayPeach},
  ];

  static const Map<String, String> _itemTitleTrToEn = {
    'Önden açılan lohusa geceliği / pijama (2 takım)': 'Front-opening nursing nightgown / pajamas (2 sets)',
    'Emzirme sütyeni & yıkanabilir göğüs pedleri': 'Nursing bra & washable breast pads',
    'Göğüs ucu bakım kremi (Lanolin)': 'Nipple care cream (Lanolin)',
    'Organik pamuklu lohusa pedi (büyük boy)': 'Organic cotton postpartum maternity pads (large size)',
    'Kaymayan yumuşak terlik & kalın sıcak çorap': 'Non-slip soft slippers & warm socks',
    'Kimlik, hastane kartı ve doktor doğum tercih planı': 'ID card, hospital records & birth plan preferences',
    'Dudak nemlendiricisi & saç bandı/lastik': 'Lip balm & hair ties / headband',
    'Diş fırçası, macun & seyahat boy şampuan': 'Toothbrush, toothpaste & travel-size toiletries',
    'Yenidoğan hastane çıkış seti (zıbın, tulum, şapka, eldiven)': 'Newborn homecoming outfit (onesie, hat, mittens)',
    'Yenidoğan bebek bezi (1 paket mini boy)': 'Newborn diapers (1 small pack)',
    'Yumuşak müslin örtü & pamuklu kundak battaniyesi': 'Soft muslin swaddle & cotton receiving blanket',
    'Alkolsüz yenidoğan ıslak mendili / pamuk': 'Alcohol-free newborn wipes / cotton pads',
    'Doğal pişik önleyici krem': 'Natural barrier diaper rash cream',
    'Yenidoğan anakucağı / oto koltuğu (hastane çıkışı için)': 'Infant car seat (approved for discharge)',
    'Rahat yedek tişört & eşofman altı': 'Comfortable spare t-shirt & lounge pants',
    'Uzun kablolu telefon şarj aleti & powerbank': 'Long phone charging cable & portable powerbank',
    'Sağlıklı atıştırmalıklar (kuruyemiş, meyve barları)': 'Healthy snacks (nuts, dried fruits, energy bars)',
    'Termos matarada taze su': 'Insulated water flask with fresh water',
    'Otopark ve otomat için nakit bozuk para': 'Spare cash / coins for parking and vending machines',
  };

  String _getLocalizedTitle(String title) {
    if (context.locale.languageCode == 'en') {
      return _itemTitleTrToEn[title] ?? title;
    }
    return title;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadItems();
    DatabaseHelper.appDataRevision.addListener(_loadItems);
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_loadItems);
    _tabController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseHelper.instance.getHospitalBagItems();
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  double get _progress {
    if (_items.isEmpty) return 0.0;
    final packed = _items.where((i) => i.isPacked).length;
    return packed / _items.length;
  }

  Future<void> _toggleItem(HospitalBagItem item) async {
    HapticFeedback.lightImpact();
    if (item.id != null) {
      await DatabaseHelper.instance.toggleHospitalBagItem(item.id!, !item.isPacked);
    }
  }

  Future<void> _addItem(String category) async {
    final title = _newItemController.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.mediumImpact();
    await DatabaseHelper.instance.insertHospitalBagItem(
      HospitalBagItem(
        category: category,
        title: title,
        isCustom: true,
      ),
    );
    _newItemController.clear();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showAddDialog(String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'hospital_bag_add_dialog_title'.tr(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
        ),
        content: TextField(
          controller: _newItemController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'hospital_bag_add_dialog_hint'.tr(),
            hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('doctor_vault_btn_cancel'.tr(), style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => _addItem(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('hospital_bag_add_btn'.tr(), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                          child: _buildProgressCard(percent),
                        ),
                        _buildTabBar(),
                        const SizedBox(height: 12),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: _categories.map((cat) {
                              final catItems = _items.where((i) => i.category == cat['key']).toList();
                              return _buildCategoryTab(catItems, cat['key'] as String);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentCatKey = _categories[_tabController.index]['key'] as String;
          _showAddDialog(currentCatKey);
        },
        backgroundColor: AppColors.primaryPink,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'hospital_bag_btn_add'.tr(),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
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
                  'hospital_bag_appbar_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'hospital_bag_appbar_sub'.tr(),
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
              color: AppColors.clayPeach,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🎒', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int percent) {
    return ClayCard(
      color: AppColors.clayMint,
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'hospital_bag_status_packed'.tr(args: [percent.toString()]),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '%$percent',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: percent == 100 ? AppColors.successGreen : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percent == 100
                ? 'hospital_bag_all_done'.tr()
                : 'hospital_bag_progress_text'.tr(args: [
                    _items.where((i) => i.isPacked).length.toString(),
                    _items.length.toString(),
                  ]),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryPink,
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: _categories.map((c) {
          return Tab(
            text: '${c['emoji']} ${(c['titleKey'] as String).tr()}',
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTab(List<HospitalBagItem> list, String category) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎒', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              'hospital_bag_empty_title'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'hospital_bag_empty_sub'.tr(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 84),
          ],
        ),
      );
    }

    final packedList = list.where((i) => i.isPacked).toList();
    final unpackedList = list.where((i) => !i.isPacked).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        if (unpackedList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Text(
              'hospital_bag_unpacked_heading'.tr(args: [unpackedList.length.toString()]),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...unpackedList.map((item) => _buildItemCard(item)),
        ],
        if (packedList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
            child: Text(
              'hospital_bag_packed_heading'.tr(args: [packedList.length.toString()]),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.successGreen,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...packedList.map((item) => _buildItemCard(item)),
        ],
        const SizedBox(height: 84),
      ],
    );
  }

  Widget _buildItemCard(HospitalBagItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleItem(item),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: item.isPacked ? AppColors.itemPackedGreenBg : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: item.isPacked ? AppColors.successGreen.withValues(alpha: 0.3) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.isPacked ? AppColors.successGreen : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.isPacked ? AppColors.successGreen : AppColors.textMuted.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: item.isPacked
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedTitle(item.title),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: item.isPacked ? FontWeight.w500 : FontWeight.w600,
                          color: item.isPacked ? AppColors.textMuted : AppColors.primaryDark,
                          decoration: item.isPacked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (item.isCustom)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'hospital_bag_custom_tag'.tr(),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (item.isCustom)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.medicalAlertRed),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await DatabaseHelper.instance.deleteHospitalBagItem(item.id!);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
