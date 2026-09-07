import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/birth_plan_model.dart';
import '../../../models/profile_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/birth_plan_pdf_service.dart';

/// Aura Pregnancy - Tam Ekran Kişisel Doğum Planı & Altın Mühürlü PDF Ekranı
class BirthPlanScreen extends StatefulWidget {
  final ProfileModel? profile;

  const BirthPlanScreen({super.key, this.profile});

  static Future<void> open(BuildContext context, {ProfileModel? profile}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BirthPlanScreen(profile: profile)),
    );
  }

  @override
  State<BirthPlanScreen> createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends State<BirthPlanScreen> {
  BirthPlanModel _plan = const BirthPlanModel();
  bool _isLoading = true;
  bool _isExporting = false;
  final TextEditingController _specialWishesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _specialWishesController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    final plan = await DatabaseHelper.instance.getBirthPlan();
    if (mounted) {
      setState(() {
        _plan = plan;
        _specialWishesController.text = plan.specialWishes;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePlan(BirthPlanModel newPlan) async {
    HapticFeedback.selectionClick();
    setState(() => _plan = newPlan);
    await DatabaseHelper.instance.saveBirthPlan(newPlan);
  }

  Future<void> _exportPdf() async {
    HapticFeedback.mediumImpact();
    setState(() => _isExporting = true);
    try {
      final updatedPlan = _plan.copyWith(specialWishes: _specialWishesController.text.trim());
      await DatabaseHelper.instance.saveBirthPlan(updatedPlan);
      await BirthPlanPdfService.instance.generateAndShareBirthPlan(
        profile: widget.profile,
        plan: updatedPlan,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturma hatası: $e'),
            backgroundColor: AppColors.medicalAlertRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIntroCard(),
                          const SizedBox(height: 16),
                          _buildSectionTitle('ORTAM VE DOĞUM ATMOSFERİ', '🌿'),
                          _buildPreferenceTile(
                            title: 'Loş Işık ve Sessiz Ortam',
                            subtitle: 'Oksitosin salgısını artıran loş, huzurlu doğum odası',
                            value: _plan.dimLights,
                            color: AppColors.clayLavender,
                            onChanged: (v) => _updatePlan(_plan.copyWith(dimLights: v)),
                          ),
                          _buildPreferenceTile(
                            title: 'Rahatlatıcı Ortam Müziği',
                            subtitle: 'Kişisel doğum müzik listemin arka planda çalınması',
                            value: _plan.ambientMusic,
                            color: AppColors.claySky,
                            onChanged: (v) => _updatePlan(_plan.copyWith(ambientMusic: v)),
                          ),
                          _buildPreferenceTile(
                            title: 'Aromaterapi & Uçucu Yağlar',
                            subtitle: 'Lavanta, adaçayı gibi gevşetici kokuların kullanımı',
                            value: _plan.aromatherapy,
                            color: AppColors.clayMint,
                            onChanged: (v) => _updatePlan(_plan.copyWith(aromatherapy: v)),
                          ),
                          _buildPreferenceTile(
                            title: 'Pilates Topu & Aktif Hareket',
                            subtitle: 'Doğum dalgaları sırasında pilates topu ile rahatlama',
                            value: _plan.birthingBall,
                            color: AppColors.clayPeach,
                            onChanged: (v) => _updatePlan(_plan.copyWith(birthingBall: v)),
                          ),
                          const SizedBox(height: 18),
                          _buildSectionTitle('BEBEĞİN İLK DAKİKALARI & TIBBİ YAKLAŞIM', '👶'),
                          _buildPreferenceTile(
                            title: 'Kordonun Geç Kesilmesi',
                            subtitle: 'Plasentadaki kanın bebeğe tam geçişi için 1-3 dakika bekleme',
                            value: _plan.delayedCordClamping,
                            color: AppColors.clayRose,
                            onChanged: (v) => _updatePlan(_plan.copyWith(delayedCordClamping: v)),
                          ),
                          _buildPreferenceTile(
                            title: 'Kordonu Eşimin Kesmesi',
                            subtitle: 'Doğum anında göbek kordonunun partnerim tarafından kesilmesi',
                            value: _plan.partnerCutsCord,
                            color: AppColors.claySky,
                            onChanged: (v) => _updatePlan(_plan.copyWith(partnerCutsCord: v)),
                          ),
                          _buildPreferenceTile(
                            title: 'Anında Ten Tene Temas (Altın Saat)',
                            subtitle: 'Bebek doğar doğmaz göğsüme yatırılarak ilk bağın kurulması',
                            value: _plan.immediateSkinToSkin,
                            color: AppColors.clayPeach,
                            onChanged: (v) => _updatePlan(_plan.copyWith(immediateSkinToSkin: v)),
                          ),
                          _buildPreferenceTile(
                            title: 'İlk 24 Saat Yıkamanın Ertelenmesi',
                            subtitle: 'Verniks tabakasının cildi koruması için banyonun geciktirilmesi',
                            value: _plan.delayNewbornBath24h,
                            color: AppColors.clayMint,
                            onChanged: (v) => _updatePlan(_plan.copyWith(delayNewbornBath24h: v)),
                          ),
                          const SizedBox(height: 18),
                          _buildSectionTitle('ÖZEL DİLEKLER VE HEKİM NOTLARI', '✍️'),
                          ClayCard(
                            color: Colors.white,
                            borderRadius: 20,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hekiminize veya Ebe Ekibinize Özel İstekleriniz:',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _specialWishesController,
                                  maxLines: 4,
                                  onChanged: (text) {
                                    _plan = _plan.copyWith(specialWishes: text);
                                    DatabaseHelper.instance.saveBirthPlan(_plan);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Örn: Doğum salonunda yalnızca eşim bulunsun, epizyotomi sadece tıbbi zorunlulukta uygulansın...',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildExportButton(),
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
                  'Doğum Planı',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Altın Mühürlü Hekim & Ebe Rehberi',
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
            child: const Text('📜', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return ClayCard(
      color: AppColors.clayLavender,
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Huzurlu ve Bilinçli Doğum Tercihleri',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu tercihler doğumhanede hekiminiz ve ebeniz ile ortak bir dilde buluşmanızı sağlar. Dilediğiniz zaman PDF olarak çıktı alıp doktorunuza sunabilirsiniz.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClayCard(
        color: color,
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeThumbColor: AppColors.primaryPink,
              activeTrackColor: AppColors.primaryPink.withValues(alpha: 0.3),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isExporting ? null : _exportPdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isExporting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📜', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    'Altın Mühürlü PDF Oluştur & Paylaş',
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
