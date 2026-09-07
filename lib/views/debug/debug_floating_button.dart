import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/debug_panel_bottom_sheet.dart';

/// Aura Pregnancy - Sağ Kenarda Sabit Yüzen Geliştirici & Test Butonu
class DebugFloatingButton extends StatelessWidget {
  final VoidCallback onDataChanged;

  const DebugFloatingButton({super.key, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height * 0.42,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => DebugPanelBottomSheet(onDataChanged: onDataChanged),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary, // Koyu şık kontrast
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                offset: const Offset(-2, 4),
                blurRadius: 10,
              ),
            ],
            border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛠️', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                'Debug',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
