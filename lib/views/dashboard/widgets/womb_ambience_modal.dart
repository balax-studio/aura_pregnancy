import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';

import '../screens/womb_ambience_screen.dart';

/// Aura Pregnancy - Rahim İçi Sakinleşme Çanı & Akustik Beyaz Gürültü Modalı
class WombAmbienceModal extends StatefulWidget {
  const WombAmbienceModal({super.key});

  static Future<void> show(BuildContext context) {
    return WombAmbienceScreen.open(context);
  }

  @override
  State<WombAmbienceModal> createState() => _WombAmbienceModalState();
}

class _WombAmbienceModalState extends State<WombAmbienceModal> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _selectedTrackIndex = 0;
  bool _isPlaying = false;
  double _volume = 0.75;
  int _timerMinutes = 30;
  int _secondsLeft = 1800;
  Timer? _countdownTimer;

  final List<Map<String, String>> _tracks = [
    {
      'title': 'Anne Nabzı (60 BPM)',
      'subtitle': 'Rahim içi ritmik kalp atışı ve huzur',
      'emoji': '💗',
    },
    {
      'title': 'Amniyotik Sıvı Dalgaları',
      'subtitle': 'Suyun rahatlatıcı derin uğultusu',
      'emoji': '🌊',
    },
    {
      'title': 'Pembe Gürültü & Ilık Yağmur',
      'subtitle': 'Hamilelik uykusuzluğunu gideren tını',
      'emoji': '🌧️',
    },
    {
      'title': 'Sakinleştirici Ninni Kutusu',
      'subtitle': 'Yenidoğan ve kolik yatıştırıcı melodi',
      'emoji': '🧸',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // 60 BPM = 1 beat per second
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _countdownTimer?.cancel();
      }
    });
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
          if (mounted) setState(() => _isPlaying = false);
        }
      });
    }
  }

  String get _formattedTimeLeft {
    if (_timerMinutes == 0) return 'Sürekli Çalma';
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final activeTrack = _tracks[_selectedTrackIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                    color: AppColors.clayRose,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('🎧', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rahim İçi Sakinleşme Çanı',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Hamilelik Uykusu & Kolik Sakinleştirici',
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
          const SizedBox(height: 16),

          // 60 BPM Nabız Alanı ve Aktif Parça
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Animasyonlu Kalp / Dalga Rozeti
                  ScaleTransition(
                    scale: _isPlaying ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.clayRose,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: _isPlaying ? 0.35 : 0.15),
                            blurRadius: _isPlaying ? 30 : 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          activeTrack['emoji']!,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    activeTrack['title']!,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeTrack['subtitle']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Kalan Süre Sayacı
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.clayCardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: AppColors.primaryPink),
                        const SizedBox(width: 6),
                        Text(
                          _formattedTimeLeft,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Çalma / Durdurma Ana Butonu
                  GestureDetector(
                    onTap: _togglePlay,
                    child: ClayCard(
                      color: _isPlaying ? AppColors.primaryPink : AppColors.clayPeach,
                      borderRadius: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: _isPlaying ? Colors.white : AppColors.primaryPink,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isPlaying ? 'Sakinleşmeyi Duraklat' : 'Sakinleşmeyi Başlat',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _isPlaying ? Colors.white : AppColors.primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Parça Seçenekleri
                  ...List.generate(_tracks.length, (index) {
                    final t = _tracks[index];
                    final isSelected = index == _selectedTrackIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedTrackIndex = index;
                            if (_isPlaying) _startTimer();
                          });
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: ClayCard(
                          color: isSelected ? AppColors.clayLavender : AppColors.clayCardSurface,
                          borderRadius: 18,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Text(t['emoji']!, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t['title']!,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      t['subtitle']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.lavenderPurple, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // Zamanlayıcı Seçenekleri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimerChip('15 dk', 15),
                      const SizedBox(width: 8),
                      _buildTimerChip('30 dk', 30),
                      const SizedBox(width: 8),
                      _buildTimerChip('60 dk', 60),
                      const SizedBox(width: 8),
                      _buildTimerChip('Sürekli', 0),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Ses Seviyesi Sürgüsü
                  Row(
                    children: [
                      const Icon(Icons.volume_down_rounded, color: AppColors.textMuted, size: 20),
                      Expanded(
                        child: Slider(
                          value: _volume,
                          activeColor: AppColors.primaryPink,
                          inactiveColor: AppColors.clayCardSurface,
                          onChanged: (val) {
                            setState(() => _volume = val);
                          },
                        ),
                      ),
                      const Icon(Icons.volume_up_rounded, color: AppColors.textMuted, size: 20),
                    ],
                  ),
                  const SizedBox(height: 84),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerChip(String label, int minutes) {
    final isSelected = _timerMinutes == minutes;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _timerMinutes = minutes;
          _startTimer();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : AppColors.clayCardSurface,
          borderRadius: BorderRadius.circular(12),
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
}
