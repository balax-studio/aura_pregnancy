import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/clay_theme.dart';
import '../../services/fruit_asset_sync.dart';

/// Aura Pregnancy - 3D Render Meyve & Sebze Fotoğraf Bileşeni
class Fruit3DWidget extends StatelessWidget {
  final String? fruitKey;
  final int? week;
  final int? stageIndex;
  final double size;
  final double borderRadius;
  final bool showShadow;

  const Fruit3DWidget({
    super.key,
    this.fruitKey,
    this.week,
    this.stageIndex,
    this.size = 56.0,
    this.borderRadius = 28.0,
    this.showShadow = true,
  });

  String _resolveFruitKey() {
    if (fruitKey != null && fruitKey!.isNotEmpty) return fruitKey!;
    if (stageIndex != null) return Fruit3DAssetManager.getFruitKeyForStageIndex(stageIndex!);
    if (week != null) return Fruit3DAssetManager.getFruitKeyForWeek(week!);
    return 'avocado';
  }

  @override
  Widget build(BuildContext context) {
    final key = _resolveFruitKey();
    final assetPath = Fruit3DAssetManager.getAssetImagePath(key);

    return Container(
      width: size,
      height: size,
      decoration: showShadow
          ? ClayTheme.clayDecoration(
              color: _getFruitBgColor(key),
              borderRadius: borderRadius,
            )
          : BoxDecoration(
              color: _getFruitBgColor(key),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) {
            return Container(
              color: _getFruitBgColor(key),
              child: Center(
                child: Icon(
                  _getFruitIcon(key),
                  size: size * 0.45,
                  color: _getFruitShadowColor(key).withValues(alpha: 0.65),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static IconData _getFruitIcon(String key) {
    switch (key) {
      case 'carrot': return Icons.eco_rounded;
      case 'papaya': return Icons.circle_rounded;
      case 'cauliflower': return Icons.spa_rounded;
      case 'zucchini': return Icons.grass_rounded;
      case 'broccoli': return Icons.park_rounded;
      case 'squash': return Icons.circle_rounded;
      case 'butternut_squash': return Icons.circle_rounded;
      case 'cabbage': return Icons.spa_rounded;
      case 'bok_choy': return Icons.grass_rounded;
      case 'pumpkin': return Icons.circle_rounded;
      case 'lettuce': return Icons.spa_rounded;
      case 'swiss_chard': return Icons.grass_rounded;
      case 'celery': return Icons.spa_rounded;
      case 'mini_watermelon': return Icons.circle_rounded;
      default: return Icons.eco_rounded;
    }
  }

  static Color _getFruitBgColor(String key) {
    switch (key) {
      case 'avocado': return AppColors.fruitBgGreenPastel;
      case 'strawberry': return AppColors.fruitBgRosePastel;
      case 'lemon': return AppColors.fruitBgLemonPastel;
      case 'banana': return AppColors.fruitBgBananaPastel;
      case 'blueberry': return AppColors.fruitBgBluePastel;
      case 'pineapple': return AppColors.fruitBgPineapplePastel;
      case 'watermelon': return AppColors.fruitBgWatermelonPastel;
      case 'peach': return AppColors.fruitBgPeachPastel;
      case 'corn': return AppColors.fruitBgBananaPastel;
      case 'eggplant': return AppColors.fruitBgEggplantPastel;
      case 'coconut': return AppColors.fruitBgCoconutPastel;
      case 'melon': return AppColors.fruitBgMelonPastel;
      case 'seed': return AppColors.fruitBgGreenPastel;
      case 'carrot': return AppColors.fruitBgPeachPastel;
      case 'papaya': return AppColors.fruitBgMelonPastel;
      case 'cauliflower': return AppColors.fruitBgCoconutPastel;
      case 'zucchini': return AppColors.fruitBgGreenPastel;
      case 'broccoli': return AppColors.fruitBgGreenPastel;
      case 'squash': return AppColors.fruitBgMelonPastel;
      case 'butternut_squash': return AppColors.fruitBgPineapplePastel;
      case 'cabbage': return AppColors.fruitBgWatermelonPastel;
      case 'bok_choy': return AppColors.fruitBgGreenPastel;
      case 'pumpkin': return AppColors.fruitBgPeachPastel;
      case 'lettuce': return AppColors.fruitBgGreenPastel;
      case 'swiss_chard': return AppColors.fruitBgWatermelonPastel;
      case 'celery': return AppColors.fruitBgGreenPastel;
      case 'mini_watermelon': return AppColors.fruitBgWatermelonPastel;
      default: return AppColors.clayPeach;
    }
  }

  static Color _getFruitShadowColor(String key) {
    switch (key) {
      case 'avocado': return AppColors.fruitAccentGreen;
      case 'strawberry': return AppColors.fruitAccentRed;
      case 'lemon': return AppColors.fruitAccentYellow;
      case 'banana': return AppColors.fruitAccentOrange;
      case 'blueberry': return AppColors.fruitAccentDeepBlue;
      case 'pineapple': return AppColors.fruitAccentAmber;
      case 'watermelon': return AppColors.fruitAccentDeepGreen;
      case 'peach': return AppColors.fruitAccentCoral;
      case 'corn': return AppColors.fruitAccentOrange;
      case 'eggplant': return AppColors.fruitAccentPurple;
      case 'coconut': return AppColors.fruitAccentBrown;
      case 'melon': return AppColors.fruitAccentWarmOrange;
      case 'seed': return AppColors.fruitAccentForest;
      case 'carrot': return AppColors.fruitAccentCoral;
      case 'papaya': return AppColors.fruitAccentWarmOrange;
      case 'cauliflower': return AppColors.fruitAccentBrown;
      case 'zucchini': return AppColors.fruitAccentGreen;
      case 'broccoli': return AppColors.fruitAccentDeepGreen;
      case 'squash': return AppColors.fruitAccentWarmOrange;
      case 'butternut_squash': return AppColors.fruitAccentAmber;
      case 'cabbage': return AppColors.fruitAccentDeepGreen;
      case 'bok_choy': return AppColors.fruitAccentGreen;
      case 'pumpkin': return AppColors.fruitAccentCoral;
      case 'lettuce': return AppColors.fruitAccentGreen;
      case 'swiss_chard': return AppColors.fruitAccentDeepGreen;
      case 'celery': return AppColors.fruitAccentGreen;
      case 'mini_watermelon': return AppColors.fruitAccentDeepGreen;
      default: return AppColors.primaryPink;
    }
  }
}
