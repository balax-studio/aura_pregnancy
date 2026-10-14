import 'package:flutter/material.dart';
import 'real_womb_fetus_widget.dart';

/// Aura Pregnancy - 360° İnteraktif 3D Anne Karnı Fetus Modeli
class Interactive3DFetusWidget extends StatefulWidget {
  final int currentWeek;
  final int currentDay; // Remaining gestational days, 0-6
  final String babyName;
  final String eddDate;
  final VoidCallback? onTap;

  const Interactive3DFetusWidget({
    super.key,
    required this.currentWeek,
    this.currentDay = 3,
    this.babyName = 'Bebeğimiz',
    this.eddDate = '2026-10-15',
    this.onTap,
  });

  @override
  State<Interactive3DFetusWidget> createState() => _Interactive3DFetusWidgetState();
}

class _Interactive3DFetusWidgetState extends State<Interactive3DFetusWidget> {

  @override
  Widget build(BuildContext context) {
    final week = widget.currentWeek;
    final day = widget.currentDay;

    // Gerçekçi Lennart Nilsson rahim içi canlı fetüs ve kordon motoru
    return RealWombFetusWidget(
      currentWeek: week,
      currentDay: day,
      babyName: widget.babyName,
      eddDate: widget.eddDate,
      onTap: widget.onTap,
    );
  }
}
