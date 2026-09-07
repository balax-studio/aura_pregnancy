import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../services/calm_audio_service.dart';

/// Aura Pregnancy - Sakinleşme Çanı, Rahim İçi Sesler & Akustik Rahatlama Odası
/// Harici ses dosyası indirmeye gerek kalmadan, saf matematiksel frekans sentezleyicisi ile ses üretir.
class WombAmbienceScreen extends StatefulWidget {
  const WombAmbienceScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WombAmbienceScreen()),
    );
  }

  @override
  State<WombAmbienceScreen> createState() => _WombAmbienceScreenState();
}

class _WombAmbienceScreenState extends State<WombAmbienceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _selectedTrackIndex = 0;
  bool _isPlaying = false;
  bool _isBuffering = false;
  double _volume = 0.75;
  int _timerMinutes = 30;
  int _secondsLeft = 1800;
  Timer? _countdownTimer;

  final List<Map<String, String>> _tracks = const [
    {
      'id': 'calm_bell',
      'titleKey': 'womb_track_0_title',
      'subtitleKey': 'womb_track_0_desc',
      'emoji': '🔔',
    },
    {
      'id': 'heartbeat',
      'titleKey': 'womb_track_1_title',
      'subtitleKey': 'womb_track_1_desc',
      'emoji': '💗',
    },
    {
      'id': 'amniotic_fluid',
      'titleKey': 'womb_track_2_title',
      'subtitleKey': 'womb_track_2_desc',
      'emoji': '💧',
    },
    {
      'id': 'pink_rain',
      'titleKey': 'womb_track_3_title',
      'subtitleKey': 'womb_track_3_desc',
      'emoji': '🌧️',
    },
    {
      'id': 'white_noise',
      'titleKey': 'womb_track_white_title',
      'subtitleKey': 'womb_track_white_desc',
      'emoji': '💨',
    },
    {
      'id': 'lullaby_box',
      'titleKey': 'womb_track_4_title',
      'subtitleKey': 'womb_track_4_desc',
      'emoji': '🧸',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Ses motorunu arka planda ön ısıt
    CalmAudioService.instance.init();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    CalmAudioService.instance.pause();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    HapticFeedback.mediumImpact();
    if (_isPlaying) {
      _countdownTimer?.cancel();
      setState(() => _isPlaying = false);
      await CalmAudioService.instance.pause();
    } else {
      setState(() {
        _isPlaying = true;
        _isBuffering = true;
      });
      _startTimer();
      final trackId = _tracks[_selectedTrackIndex]['id']!;
      await CalmAudioService.instance.playTrack(trackId, volume: _volume);
      if (mounted) setState(() => _isBuffering = false);
    }
  }

  Future<void> _switchTrack(int index) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTrackIndex = index;
    });

    if (_isPlaying) {
      setState(() => _isBuffering = true);
      final trackId = _tracks[index]['id']!;
      await CalmAudioService.instance.playTrack(trackId, volume: _volume);
      if (mounted) setState(() => _isBuffering = false);
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    if (_timerMinutes > 0) {
      _secondsLeft = _timerMinutes * 60;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft > 0) {
          if (mounted) setState(() => _secondsLeft--);
        } else {
          t.cancel();
          CalmAudioService.instance.pause();
          if (mounted) setState(() => _isPlaying = false);
        }
      });
    }
  }

  String get _formattedTimeLeft {
    if (_timerMinutes == 0) return 'womb_timer_continuous'.tr();
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  IconData _getTrackIcon(String id) {
    switch (id) {
      case 'calm_bell':
        return Icons.notifications_active_rounded;
      case 'heartbeat':
        return Icons.favorite_rounded;
      case 'amniotic_fluid':
        return Icons.water_drop_rounded;
      case 'pink_rain':
        return Icons.cloud_rounded;
      case 'white_noise':
        return Icons.air_rounded;
      case 'lullaby_box':
      default:
        return Icons.music_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTrack = _tracks[_selectedTrackIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Nabız Kalp Efekti & Çalma Durumu
                    ScaleTransition(
                      scale: _isPlaying ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isPlaying ? AppColors.clayRose : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: (_isPlaying ? AppColors.primaryPink : Colors.black).withValues(alpha: 0.15),
                              offset: const Offset(0, 16),
                              blurRadius: 32,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isBuffering
                              ? const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppColors.primaryPink,
                                  ),
                                )
                              : Icon(
                                  _getTrackIcon(activeTrack['id']!),
                                  size: 54,
                                  color: AppColors.primaryPink,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      activeTrack['titleKey']!.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeTrack['subtitleKey']!.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Kalan Zaman Göstergesi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlaying ? Icons.timer_outlined : Icons.timer_off_outlined,
                            size: 16,
                            color: _isPlaying ? AppColors.primaryPink : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isPlaying
                                ? 'womb_timer_remaining'.tr(args: [_formattedTimeLeft])
                                : 'womb_timer_sleep'.tr(args: [
                                    _timerMinutes == 0
                                        ? 'womb_timer_continuous'.tr()
                                        : 'womb_timer_min'.tr(args: ['$_timerMinutes'])
                                  ]),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isPlaying ? AppColors.primaryPink : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Büyük Oynat / Durdur Butonu
                    ClayButton(
                      onPressed: _togglePlay,
                      color: AppColors.primaryPink,
                      borderRadius: 36,
                      width: 72,
                      height: 72,
                      padding: EdgeInsets.zero,
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Ses Düzeyi Kontrolü
                    ClayCard(
                      color: Colors.white,
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.volume_down_rounded, color: AppColors.textMuted, size: 20),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primaryPink,
                                inactiveTrackColor: AppColors.background,
                                thumbColor: AppColors.primaryPink,
                                overlayColor: AppColors.primaryPink.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: _volume,
                                onChanged: (v) {
                                  setState(() => _volume = v);
                                  CalmAudioService.instance.setVolume(v);
                                },
                              ),
                            ),
                          ),
                          const Icon(Icons.volume_up_rounded, color: AppColors.textPrimary, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Zamanlayıcı Seçenekleri
                    _buildTimerSelector(),
                    const SizedBox(height: 20),
                    // Parça Seçim Listesi
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'SES VE AMBİYANS LİSTESİ',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(_tracks.length, (index) {
                      final track = _tracks[index];
                      final isSelected = _selectedTrackIndex == index;
                      return _buildTrackTile(track, index, isSelected);
                    }),
                    const SizedBox(height: 84), // Alt gezinme barı payı
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
                  'womb_ambience_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'womb_ambience_subtitle'.tr(),
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
              color: AppColors.clayRose,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.headphones_rounded, size: 20, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSelector() {
    final options = [15, 30, 45, 60, 0];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((mins) {
          final isSelected = _timerMinutes == mins;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _timerMinutes = mins;
                  _secondsLeft = mins * 60;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryPink : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  mins == 0 ? 'womb_timer_continuous'.tr() : '$mins dk',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrackTile(Map<String, String> track, int index, bool isSelected) {
    return ClayCard(
      color: isSelected ? AppColors.clayRose : AppColors.clayCardSurface,
      borderRadius: 20,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () => _switchTrack(index),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryPink : AppColors.primaryPink.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getTrackIcon(track['id']!),
              color: isSelected ? Colors.white : AppColors.primaryPink,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track['titleKey']!.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  track['subtitleKey']!.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected && _isPlaying)
            const Icon(Icons.graphic_eq_rounded, color: AppColors.primaryPink, size: 24)
          else
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded,
              color: isSelected ? AppColors.primaryPink : AppColors.textMuted,
              size: 24,
            ),
        ],
      ),
    );
  }
}
