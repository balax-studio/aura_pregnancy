import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/hospital_bag_item.dart';
import '../../../services/database_helper.dart';

/// Aura Pregnancy - Akıllı Doğum Çantası & Hastane Hazırlık Listesi Modal Sheet
class HospitalBagSheet extends StatefulWidget {
  const HospitalBagSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HospitalBagSheet(),
    );
  }

  @override
  State<HospitalBagSheet> createState() => _HospitalBagSheetState();
}

class _HospitalBagSheetState extends State<HospitalBagSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _newItemController = TextEditingController();
  List<HospitalBagItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    await DatabaseHelper.instance.toggleHospitalBagItem(item.id!, !item.isPacked);
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
      Navigator.of(context).pop(); // Close add dialog
    }
  }

  void _showAddDialog(String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Özel Eşya Ekle',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
        ),
        content: TextField(
          controller: _newItemController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Örn: Fotoğraf makinesi, lohusa tacı...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => _addItem(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Ekle', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final momItems = _items.where((i) => i.category == 'mom').toList();
    final babyItems = _items.where((i) => i.category == 'baby').toList();
    final partnerItems = _items.where((i) => i.category == 'partner').toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Tutamaç
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

          // Başlık ve İlerleme Alanı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.clayPeach,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('🎒', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doğum & Hastane Çantası',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        '28. Haftadan İtibaren Eksiksiz Hazırlık',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // İlerleme Yüzdesi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '%${(_progress * 100).toInt()} Hazır',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Canlı İlerleme Çubuğu (Progress Bar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.clayCardSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3 Kategori Sekmesi
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.clayCardSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: '🤰 Anne (${momItems.where((i) => i.isPacked).length}/${momItems.length})'),
                Tab(text: '👶 Bebek (${babyItems.where((i) => i.isPacked).length}/${babyItems.length})'),
                Tab(text: '👨‍👩‍👦 Refakatçi (${partnerItems.where((i) => i.isPacked).length}/${partnerItems.length})'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Liste Görünümü
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildItemList(momItems, 'mom'),
                      _buildItemList(babyItems, 'baby'),
                      _buildItemList(partnerItems, 'partner'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(List<HospitalBagItem> list, String category) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                child: ClayCard(
                  color: item.isPacked ? AppColors.clayMint : AppColors.clayCardSurface,
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Yaylanan Kontrol Kutusu
                      GestureDetector(
                        onTap: () => _toggleItem(item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.elasticOut,
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: item.isPacked ? AppColors.successGreen : Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: item.isPacked ? AppColors.successGreen : AppColors.textMuted.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: item.isPacked
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: item.isPacked ? FontWeight.w500 : FontWeight.w600,
                            color: item.isPacked ? AppColors.textMuted : AppColors.textPrimary,
                            decoration: item.isPacked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (item.isCustom)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                          onPressed: () async {
                            HapticFeedback.selectionClick();
                            await DatabaseHelper.instance.deleteHospitalBagItem(item.id!);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Alt Ekleme Butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: InkWell(
            onTap: () => _showAddDialog(category),
            borderRadius: BorderRadius.circular(18),
            child: ClayCard(
              color: AppColors.clayPeach,
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryPink, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bu Listeye Özel Eşya Ekle',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
