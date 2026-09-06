import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/inset_box_shadow.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';

/// Claymorphic Günlük Yürüyüş & Adım Takip Kartı
/// Hem süre (dakika) hem de adım sayısı ile hızlı veya manuel ekleme desteği sunar.
class WalkingTrackerCard extends StatefulWidget {
  final int stepCount;
  final int walkingMinutes;
  final int currentWeek;
  final Function(int steps, {int minutes}) onAddSteps;
  final VoidCallback onReset;

  const WalkingTrackerCard({
    super.key,
    required this.stepCount,
    required this.walkingMinutes,
    this.currentWeek = 12,
    required this.onAddSteps,
    required this.onReset,
  });

  @override
  State<WalkingTrackerCard> createState() => _WalkingTrackerCardState();
}

class _WalkingTrackerCardState extends State<WalkingTrackerCard> {
  // Kart içi hızlı ekleme mod seçimi: false = Adım Modu, true = Süre Modu
  bool _isDurationMode = false;

  String _getTrimesterTip() {
    if (widget.currentWeek <= 13) {
      return 'walking_tip_t1'.tr();
    } else if (widget.currentWeek <= 26) {
      return 'walking_tip_t2'.tr();
    } else {
      return 'walking_tip_t3'.tr();
    }
  }

  void _openManualAddSheet(BuildContext context,
      {bool initialDurationMode = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WalkingManualAddSheet(
        initialDurationMode: initialDurationMode,
        onConfirm: (steps, minutes) {
          widget.onAddSteps(steps, minutes: minutes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'walking_added_toast'.tr(),
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.primaryPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const targetSteps = 6000;
    final progress = (widget.stepCount / targetSteps).clamp(0.0, 1.0);
    final isTargetReached = widget.stepCount >= targetSteps;
    final distanceKm = (widget.stepCount * 0.0007).toStringAsFixed(2);
    final burnedKcal = (widget.stepCount * 0.04).round();

    return ClayCard(
      color: isTargetReached ? AppColors.clayMint : AppColors.clayCardSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Başlık, Manuel Ekle ve Sıfırlama Butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: ClayTheme.clayDecoration(
                      color: isTargetReached
                          ? AppColors.successGreen
                          : AppColors.clayPeach,
                      borderRadius: 12,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_walk_rounded,
                        color: isTargetReached
                            ? Colors.white
                            : AppColors.secondaryPeach,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'walking_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'walking_target_desc'
                            .tr(args: [targetSteps.toString()]),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Manuel / Detaylı Ekleme Butonu
                  ClayButton(
                    color: AppColors.clayRose,
                    borderRadius: 14,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: () => _openManualAddSheet(context,
                        initialDurationMode: _isDurationMode),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 2),
                        Text(
                          'walking_add_manual'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.stepCount > 0 || widget.walkingMinutes > 0) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          size: 20, color: AppColors.textMuted),
                      onPressed: widget.onReset,
                      tooltip: 'walking_reset_tooltip'.tr(),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Adım Sayacı ve İlerleme Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: ClayTheme.clayDecoration(
              color: Colors.white,
              borderRadius: 22,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.stepCount}',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isTargetReached
                                ? AppColors.successGreen
                                : AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          isTargetReached
                              ? 'walking_target_reached'.tr()
                              : 'walking_steps_progress'.tr(args: [
                                  targetSteps.toString(),
                                  (progress * 100).toInt().toString()
                                ]),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isTargetReached
                                ? AppColors.successGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: ClayTheme.clayButtonDecoration(
                        color: isTargetReached
                            ? AppColors.clayMint
                            : AppColors.clayRose,
                        borderRadius: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTargetReached
                                ? Icons.emoji_events_rounded
                                : Icons.directions_walk_rounded,
                            size: 16,
                            color: isTargetReached
                                ? AppColors.successGreen
                                : AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isTargetReached
                                ? 'walking_status_done'.tr()
                                : 'walking_status_ongoing'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isTargetReached
                                  ? AppColors.successGreen
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // İlerleme Çubuğu (Concave Trough)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: ClayTheme.concaveDecoration(
                    color: AppColors.backgroundSubtle,
                    borderRadius: 10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isTargetReached
                            ? AppColors.successGreen
                            : AppColors.primaryPink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // İstatistik Rozetleri (Mesafe, Kalori, Süre)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('walking_stat_distance'.tr(),
                        '$distanceKm km', Icons.straighten_rounded),
                    Container(width: 1, height: 24, color: Colors.black12),
                    _buildStatItem(
                        'walking_stat_calorie'.tr(),
                        '$burnedKcal kcal',
                        Icons.local_fire_department_rounded),
                    Container(width: 1, height: 24, color: Colors.black12),
                    _buildStatItem(
                        'walking_stat_duration'.tr(),
                        'walking_minutes_short'
                            .tr(args: [widget.walkingMinutes.toString()]),
                        Icons.timer_rounded),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Mod Seçici (Toggle): Adım Sayısı vs Yürüyüş Süresi
          Container(
            padding: const EdgeInsets.all(4),
            decoration: ClayTheme.concaveDecoration(
              color: AppColors.backgroundSubtle,
              borderRadius: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDurationMode = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: !_isDurationMode
                          ? ClayTheme.clayButtonDecoration(
                              color: AppColors.clayPeach,
                              borderRadius: 12,
                            )
                          : const BoxDecoration(color: Colors.transparent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_walk_rounded,
                            size: 15,
                            color: !_isDurationMode
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'walking_tab_steps'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: !_isDurationMode
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: !_isDurationMode
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDurationMode = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: _isDurationMode
                          ? ClayTheme.clayButtonDecoration(
                              color: AppColors.clayPeach,
                              borderRadius: 12,
                            )
                          : const BoxDecoration(color: Colors.transparent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 15,
                            color: _isDurationMode
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'walking_tab_duration'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: _isDurationMode
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _isDurationMode
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
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
          const SizedBox(height: 12),

          // 4. Hızlı Ekleme Butonları (Seçili moda göre değişir)
          if (!_isDurationMode)
            // Adım Modu Butonları
            Row(
              children: [
                Expanded(
                  child: ClayButton(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () => widget.onAddSteps(500, minutes: 4),
                    child: Column(
                      children: [
                        Text('+500',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                        Text('walking_minutes_short'.tr(args: ['4']),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClayButton(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () => widget.onAddSteps(1000, minutes: 8),
                    child: Column(
                      children: [
                        Text('+1.000',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                        Text('walking_minutes_short'.tr(args: ['8']),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClayButton(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () => widget.onAddSteps(2000, minutes: 16),
                    child: Column(
                      children: [
                        Text('+2.000',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                        Text('walking_minutes_short'.tr(args: ['16']),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ClayButton(
                  color: AppColors.clayRose,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  borderRadius: 18,
                  onPressed: () =>
                      _openManualAddSheet(context, initialDurationMode: false),
                  child: const Icon(Icons.edit_note_rounded,
                      size: 20, color: AppColors.primaryDark),
                ),
              ],
            )
          else
            // Süre Modu Butonları (Dakika bazlı hızlı ekleme)
            Row(
              children: [
                Expanded(
                  child: ClayButton(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () => widget.onAddSteps(1800, minutes: 15),
                    child: Column(
                      children: [
                        Text('+15 Dk',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                        Text('~1.800 Adım',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClayButton(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () => widget.onAddSteps(3600, minutes: 30),
                    child: Column(
                      children: [
                        Text('+30 Dk',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                        Text('~3.600 Adım',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClayButton(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () => widget.onAddSteps(5400, minutes: 45),
                    child: Column(
                      children: [
                        Text('+45 Dk',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                        Text('~5.400 Adım',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ClayButton(
                  color: AppColors.clayRose,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  borderRadius: 18,
                  onPressed: () =>
                      _openManualAddSheet(context, initialDurationMode: true),
                  child: const Icon(Icons.edit_note_rounded,
                      size: 20, color: AppColors.primaryDark),
                ),
              ],
            ),
          const SizedBox(height: 12),

          // 5. Trimester Yürüyüş Tavsiye Bandı
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.claySky,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_rounded,
                        color: AppColors.waterBlue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getTrimesterTip(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.waterBlue,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.waterBlue.withValues(alpha: 0.8),
                        size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'disclaimer_walking'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: AppColors.waterBlue.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark),
        ),
      ],
    );
  }
}

/// Claymorphic Özel Yürüyüş / Adım Ekleme Bottom Sheet'i
class _WalkingManualAddSheet extends StatefulWidget {
  final bool initialDurationMode;
  final Function(int steps, int minutes) onConfirm;

  const _WalkingManualAddSheet({
    required this.initialDurationMode,
    required this.onConfirm,
  });

  @override
  State<_WalkingManualAddSheet> createState() => _WalkingManualAddSheetState();
}

class _WalkingManualAddSheetState extends State<_WalkingManualAddSheet> {
  late bool _isDurationMode;
  final TextEditingController _textController = TextEditingController();

  // Sabit oran: Hamilelik temposu ortalama ~120 adım / dakika
  static const int _stepsPerMinute = 120;

  @override
  void initState() {
    super.initState();
    _isDurationMode = widget.initialDurationMode;
    // Varsayılan değer
    _textController.text = _isDurationMode ? '20' : '2000';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  int get _parsedValue => int.tryParse(_textController.text.trim()) ?? 0;

  int get _calculatedSteps {
    if (_isDurationMode) {
      return _parsedValue * _stepsPerMinute;
    } else {
      return _parsedValue;
    }
  }

  int get _calculatedMinutes {
    if (_isDurationMode) {
      return _parsedValue;
    } else {
      return _parsedValue > 0 ? (_parsedValue / _stepsPerMinute).round() : 0;
    }
  }

  double get _calculatedKm => (_calculatedSteps * 0.0007);
  int get _calculatedKcal => (_calculatedSteps * 0.04).round();

  void _onSwitchMode(bool durationMode) {
    if (_isDurationMode == durationMode) return;
    setState(() {
      _isDurationMode = durationMode;
      _textController.text = _isDurationMode ? '20' : '2000';
    });
  }

  void _submit() {
    final value = _parsedValue;
    if (value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('walking_input_invalid'.tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onConfirm(_calculatedSteps, _calculatedMinutes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Başlık & Kapat Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'walking_sheet_title'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'walking_sheet_subtitle'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mod Seçim Sekmesi (Süre vs Adım)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onSwitchMode(true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isDurationMode
                              ? AppColors.clayPeach
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isDurationMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 18,
                              color: _isDurationMode
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'walking_tab_duration'.tr(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: _isDurationMode
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: _isDurationMode
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onSwitchMode(false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isDurationMode
                              ? AppColors.clayPeach
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: !_isDurationMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_walk_rounded,
                              size: 18,
                              color: !_isDurationMode
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'walking_tab_steps'.tr(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: !_isDurationMode
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: !_isDurationMode
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
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
            const SizedBox(height: 18),

            // Hızlı Seçim Çipleri
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _isDurationMode
                  ? [10, 15, 20, 30, 45, 60].map((mins) {
                      final isSelected =
                          _textController.text == mins.toString();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _textController.text = mins.toString();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryPink
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryPink
                                  : Colors.black12,
                            ),
                          ),
                          child: Text(
                            '$mins dk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  : [500, 1000, 2000, 3000, 5000].map((steps) {
                      final isSelected =
                          _textController.text == steps.toString();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _textController.text = steps.toString();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryPink
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryPink
                                  : Colors.black12,
                            ),
                          ),
                          child: Text(
                            '$steps adım',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
            ),
            const SizedBox(height: 16),

            // Sayısal Giriş Alanı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.secondaryPeach.withValues(alpha: 0.3),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: _isDurationMode
                      ? 'walking_field_duration'.tr()
                      : 'walking_field_steps'.tr(),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  hintText: _isDurationMode
                      ? 'walking_field_duration_hint'.tr()
                      : 'walking_field_steps_hint'.tr(),
                  suffixIcon: Icon(
                    _isDurationMode
                        ? Icons.timer_outlined
                        : Icons.directions_walk_rounded,
                    color: AppColors.secondaryPeach,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // Dinamik Canlı Bilgi & Hesaplama Kartı
            ClayCard(
              color: AppColors.clayMint,
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (_isDurationMode) ...[
                    _buildPreviewItem(
                      'walking_est_steps'.tr(),
                      '~$_calculatedSteps',
                      Icons.directions_walk_rounded,
                    ),
                  ] else ...[
                    _buildPreviewItem(
                      'walking_est_duration'.tr(),
                      '~$_calculatedMinutes dk',
                      Icons.timer_rounded,
                    ),
                  ],
                  Container(width: 1, height: 26, color: Colors.black12),
                  _buildPreviewItem(
                    'walking_stat_distance'.tr(),
                    '${_calculatedKm.toStringAsFixed(2)} km',
                    Icons.straighten_rounded,
                  ),
                  Container(width: 1, height: 26, color: Colors.black12),
                  _buildPreviewItem(
                    'walking_stat_calorie'.tr(),
                    '$_calculatedKcal kcal',
                    Icons.local_fire_department_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kaydet / Ekle Butonu
            ClayButton(
              color: AppColors.secondaryPeach,
              borderRadius: 22,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: _submit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'walking_confirm_add'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark),
        ),
      ],
    );
  }
}
