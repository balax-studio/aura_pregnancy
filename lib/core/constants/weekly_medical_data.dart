import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Aura Pregnancy - Hafta Hafta Tıbbi Bilgilendirme ve Gelişim Veritabanı (1 - 40 Hafta Eksiksiz)
class WeeklyMedicalData {
  /// Haftalık Bebek ve Anne Gelişim Verisi Modeli (1 - 40 Hafta)
  static Map<int, Map<String, dynamic>> getWeeklyData() {
    return {
      1: {
        'icon': Icons.grain_rounded,
        'fruit_name': 'week_1_fruit_name'.tr(),
        'length': '—',
        'weight': '—',
        'has_size_comparison': false,
        'baby_dev': 'week_1_baby_dev'.tr(),
        'mother_changes': 'week_1_mother_changes'.tr(),
      },
      2: {
        'icon': Icons.grain_rounded,
        'fruit_name': 'week_2_fruit_name'.tr(),
        'length': '—',
        'weight': '—',
        'has_size_comparison': false,
        'baby_dev': 'week_2_baby_dev'.tr(),
        'mother_changes': 'week_2_mother_changes'.tr(),
      },
      3: {
        'icon': Icons.spa_rounded,
        'fruit_name': 'week_3_fruit_name'.tr(),
        'length': '—',
        'weight': '—',
        'has_size_comparison': false,
        'baby_dev': 'week_3_baby_dev'.tr(),
        'mother_changes': 'week_3_mother_changes'.tr(),
      },
      4: {
        'icon': Icons.spa_rounded,
        'fruit_name': 'week_4_fruit_name'.tr(),
        'length': '2 mm',
        'weight': '< 1 gr',
        'baby_dev': 'week_4_baby_dev'.tr(),
        'mother_changes': 'week_4_mother_changes'.tr(),
      },
      5: {
        'icon': Icons.radio_button_checked_rounded,
        'fruit_name': 'week_5_fruit_name'.tr(),
        'length': '2 mm',
        'weight': '< 1 gr',
        'baby_dev': 'week_5_baby_dev'.tr(),
        'mother_changes': 'week_5_mother_changes'.tr(),
      },
      6: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_6_fruit_name'.tr(),
        'length': '6 mm',
        'weight': '< 1 gr',
        'baby_dev': 'week_6_baby_dev'.tr(),
        'mother_changes': 'week_6_mother_changes'.tr(),
      },
      7: {
        'icon': Icons.bubble_chart_rounded,
        'fruit_name': 'week_7_fruit_name'.tr(),
        'length': '10 mm',
        'weight': '~1 gr',
        'baby_dev': 'week_7_baby_dev'.tr(),
        'mother_changes': 'week_7_mother_changes'.tr(),
      },
      8: {
        'icon': Icons.scatter_plot_rounded,
        'fruit_name': 'week_8_fruit_name'.tr(),
        'length': '16 mm',
        'weight': '1.5 gr',
        'baby_dev': 'week_8_baby_dev'.tr(),
        'mother_changes': 'week_8_mother_changes'.tr(),
      },
      9: {
        'icon': Icons.lens_rounded,
        'fruit_name': 'week_9_fruit_name'.tr(),
        'length': '23 mm',
        'weight': '2 gr',
        'baby_dev': 'week_9_baby_dev'.tr(),
        'mother_changes': 'week_9_mother_changes'.tr(),
      },
      10: {
        'icon': Icons.eco_rounded,
        'fruit_name': 'week_10_fruit_name'.tr(),
        'length': '31 mm',
        'weight': '4 gr',
        'baby_dev': 'week_10_baby_dev'.tr(),
        'mother_changes': 'week_10_mother_changes'.tr(),
        'milestone_test': {
          'code': 'NIPT',
          'title': 'milestone_10_title'.tr(),
          'desc': 'milestone_10_desc'.tr(),
          'action': 'milestone_10_action'.tr()
        }
      },
      11: {
        'icon': Icons.brightness_1_rounded,
        'fruit_name': 'week_11_fruit_name'.tr(),
        'length': '41 mm',
        'weight': '7 gr',
        'baby_dev': 'week_11_baby_dev'.tr(),
        'mother_changes': 'week_11_mother_changes'.tr(),
        'milestone_test': {
          'code': 'NT_DOUBLE_START',
          'title': 'milestone_11_title'.tr(),
          'desc': 'milestone_11_desc'.tr(),
          'action': 'milestone_11_action'.tr()
        }
      },
      12: {
        'icon': Icons.brightness_high_rounded,
        'fruit_name': 'week_12_fruit_name'.tr(),
        'length': '54 mm',
        'weight': '14 gr',
        'baby_dev': 'week_12_baby_dev'.tr(),
        'mother_changes': 'week_12_mother_changes'.tr(),
        'milestone_test': {
          'code': 'DOUBLE_TEST',
          'title': 'milestone_12_title'.tr(),
          'desc': 'milestone_12_desc'.tr(),
          'action': 'milestone_12_action'.tr()
        }
      },
      13: {
        'icon': Icons.yard_rounded,
        'fruit_name': 'week_13_fruit_name'.tr(),
        'length': '7.4 cm',
        'weight': '23 gr',
        'baby_dev': 'week_13_baby_dev'.tr(),
        'mother_changes': 'week_13_mother_changes'.tr(),
      },
      14: {
        'icon': Icons.flare_rounded,
        'fruit_name': 'week_14_fruit_name'.tr(),
        'length': '8.7 cm',
        'weight': '43 gr',
        'baby_dev': 'week_14_baby_dev'.tr(),
        'mother_changes': 'week_14_mother_changes'.tr(),
      },
      15: {
        'icon': Icons.circle_notifications_rounded,
        'fruit_name': 'week_15_fruit_name'.tr(),
        'length': '10.1 cm',
        'weight': '70 gr',
        'baby_dev': 'week_15_baby_dev'.tr(),
        'mother_changes': 'week_15_mother_changes'.tr(),
      },
      16: {
        'icon': Icons.nature_rounded,
        'fruit_name': 'week_16_fruit_name'.tr(),
        'length': '11.6 cm',
        'weight': '100 gr',
        'baby_dev': 'week_16_baby_dev'.tr(),
        'mother_changes': 'week_16_mother_changes'.tr(),
        'milestone_test': {
          'code': 'TRIPLE_QUAD',
          'title': 'milestone_16_title'.tr(),
          'desc': 'milestone_16_desc'.tr(),
          'action': 'milestone_16_action'.tr()
        }
      },
      17: {
        'icon': Icons.grain_rounded,
        'fruit_name': 'week_17_fruit_name'.tr(),
        'length': '13.0 cm',
        'weight': '140 gr',
        'baby_dev': 'week_17_baby_dev'.tr(),
        'mother_changes': 'week_17_mother_changes'.tr(),
      },
      18: {
        'icon': Icons.local_florist_rounded,
        'fruit_name': 'week_18_fruit_name'.tr(),
        'length': '14.2 cm',
        'weight': '190 gr',
        'baby_dev': 'week_18_baby_dev'.tr(),
        'mother_changes': 'week_18_mother_changes'.tr(),
      },
      19: {
        'icon': Icons.brightness_medium_rounded,
        'fruit_name': 'week_19_fruit_name'.tr(),
        'length': '15.3 cm',
        'weight': '240 gr',
        'baby_dev': 'week_19_baby_dev'.tr(),
        'mother_changes': 'week_19_mother_changes'.tr(),
      },
      20: {
        'icon': Icons.wb_sunny_rounded,
        'fruit_name': 'week_20_fruit_name'.tr(),
        'length': '25.6 cm',
        'weight': '300 gr',
        'baby_dev': 'week_20_baby_dev'.tr(),
        'mother_changes': 'week_20_mother_changes'.tr(),
        'milestone_test': {
          'code': 'DETAILED_USG',
          'title': 'milestone_20_title'.tr(),
          'desc': 'milestone_20_desc'.tr(),
          'action': 'milestone_20_action'.tr()
        }
      },
      21: {
        'icon': Icons.eco_rounded,
        'fruit_name': 'week_21_fruit_name'.tr(),
        'length': '26.7 cm',
        'weight': '360 gr',
        'baby_dev': 'week_21_baby_dev'.tr(),
        'mother_changes': 'week_21_mother_changes'.tr(),
      },
      22: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_22_fruit_name'.tr(),
        'length': '27.8 cm',
        'weight': '430 gr',
        'baby_dev': 'week_22_baby_dev'.tr(),
        'mother_changes': 'week_22_mother_changes'.tr(),
      },
      23: {
        'icon': Icons.brightness_7_rounded,
        'fruit_name': 'week_23_fruit_name'.tr(),
        'length': '28.9 cm',
        'weight': '500 gr',
        'baby_dev': 'week_23_baby_dev'.tr(),
        'mother_changes': 'week_23_mother_changes'.tr(),
      },
      24: {
        'icon': Icons.grass_rounded,
        'fruit_name': 'week_24_fruit_name'.tr(),
        'length': '30.0 cm',
        'weight': '600 gr',
        'baby_dev': 'week_24_baby_dev'.tr(),
        'mother_changes': 'week_24_mother_changes'.tr(),
        'milestone_test': {
          'code': 'OGTT_DIABETES',
          'title': 'milestone_24_title'.tr(),
          'desc': 'milestone_24_desc'.tr(),
          'action': 'milestone_24_action'.tr()
        }
      },
      25: {
        'icon': Icons.nature_people_rounded,
        'fruit_name': 'week_25_fruit_name'.tr(),
        'length': '34.6 cm',
        'weight': '660 gr',
        'baby_dev': 'week_25_baby_dev'.tr(),
        'mother_changes': 'week_25_mother_changes'.tr(),
      },
      26: {
        'icon': Icons.yard_rounded,
        'fruit_name': 'week_26_fruit_name'.tr(),
        'length': '35.6 cm',
        'weight': '760 gr',
        'baby_dev': 'week_26_baby_dev'.tr(),
        'mother_changes': 'week_26_mother_changes'.tr(),
      },
      27: {
        'icon': Icons.park_rounded,
        'fruit_name': 'week_27_fruit_name'.tr(),
        'length': '36.6 cm',
        'weight': '875 gr',
        'baby_dev': 'week_27_baby_dev'.tr(),
        'mother_changes': 'week_27_mother_changes'.tr(),
      },
      28: {
        'icon': Icons.wb_twilight_rounded,
        'fruit_name': 'week_28_fruit_name'.tr(),
        'length': '37.6 cm',
        'weight': '1000 gr (1 kg)',
        'baby_dev': 'week_28_baby_dev'.tr(),
        'mother_changes': 'week_28_mother_changes'.tr(),
        'milestone_test': {
          'code': 'ANTI_D_NST',
          'title': 'milestone_28_title'.tr(),
          'desc': 'milestone_28_desc'.tr(),
          'action': 'milestone_28_action'.tr()
        }
      },
      29: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_29_fruit_name'.tr(),
        'length': '38.6 cm',
        'weight': '1150 gr',
        'baby_dev': 'week_29_baby_dev'.tr(),
        'mother_changes': 'week_29_mother_changes'.tr(),
      },
      30: {
        'icon': Icons.filter_vintage_rounded,
        'fruit_name': 'week_30_fruit_name'.tr(),
        'length': '39.9 cm',
        'weight': '1320 gr',
        'baby_dev': 'week_30_baby_dev'.tr(),
        'mother_changes': 'week_30_mother_changes'.tr(),
      },
      31: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_31_fruit_name'.tr(),
        'length': '41.1 cm',
        'weight': '1500 gr (1.5 kg)',
        'baby_dev': 'week_31_baby_dev'.tr(),
        'mother_changes': 'week_31_mother_changes'.tr(),
      },
      32: {
        'icon': Icons.star_rounded,
        'fruit_name': 'week_32_fruit_name'.tr(),
        'length': '42.4 cm',
        'weight': '1700 gr',
        'baby_dev': 'week_32_baby_dev'.tr(),
        'mother_changes': 'week_32_mother_changes'.tr(),
      },
      33: {
        'icon': Icons.spa_rounded,
        'fruit_name': 'week_33_fruit_name'.tr(),
        'length': '43.7 cm',
        'weight': '1900 gr',
        'baby_dev': 'week_33_baby_dev'.tr(),
        'mother_changes': 'week_33_mother_changes'.tr(),
      },
      34: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_34_fruit_name'.tr(),
        'length': '45.0 cm',
        'weight': '2150 gr',
        'baby_dev': 'week_34_baby_dev'.tr(),
        'mother_changes': 'week_34_mother_changes'.tr(),
      },
      35: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_35_fruit_name'.tr(),
        'length': '46.2 cm',
        'weight': '2380 gr',
        'baby_dev': 'week_35_baby_dev'.tr(),
        'mother_changes': 'week_35_mother_changes'.tr(),
      },
      36: {
        'icon': Icons.yard_rounded,
        'fruit_name': 'week_36_fruit_name'.tr(),
        'length': '47.4 cm',
        'weight': '2600 gr',
        'baby_dev': 'week_36_baby_dev'.tr(),
        'mother_changes': 'week_36_mother_changes'.tr(),
      },
      37: {
        'icon': Icons.grass_rounded,
        'fruit_name': 'week_37_fruit_name'.tr(),
        'length': '48.6 cm',
        'weight': '2850 gr',
        'baby_dev': 'week_37_baby_dev'.tr(),
        'mother_changes': 'week_37_mother_changes'.tr(),
      },
      38: {
        'icon': Icons.eco_rounded,
        'fruit_name': 'week_38_fruit_name'.tr(),
        'length': '49.8 cm',
        'weight': '3080 gr',
        'baby_dev': 'week_38_baby_dev'.tr(),
        'mother_changes': 'week_38_mother_changes'.tr(),
      },
      39: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_39_fruit_name'.tr(),
        'length': '50.7 cm',
        'weight': '3290 gr',
        'baby_dev': 'week_39_baby_dev'.tr(),
        'mother_changes': 'week_39_mother_changes'.tr(),
      },
      40: {
        'icon': Icons.circle_rounded,
        'fruit_name': 'week_40_fruit_name'.tr(),
        'length': '51.2 cm',
        'weight': '3400 gr',
        'baby_dev': 'week_40_baby_dev'.tr(),
        'mother_changes': 'week_40_mother_changes'.tr(),
      }
    };
  }

  /// Belirtilen haftanın en yakın tıbbi bilgisini döndürür
  static Map<String, dynamic> getInfoForWeek(int week) {
    final data = getWeeklyData();
    final clampedWeek = week.clamp(1, 40);
    if (data.containsKey(clampedWeek)) {
      final weekData = data[clampedWeek]!;
      return {
        ...weekData,
        'has_size_comparison': weekData['has_size_comparison'] as bool? ?? true,
        'length_basis': clampedWeek < 20 ? 'head_to_bottom' : 'head_to_heel',
      };
    }
    return data[1]!;
  }
}
