import 'package:flutter/material.dart';

/// Aura Pregnancy Pastel & Claymorphism Renk Paleti
class AppColors {
  // Arka Plan Tint & Ambient Degrade Tonları
  static const Color background = Color(0xFFFDF7F4); // Soft warm porcelain
  static const Color backgroundSubtle = Color(0xFFF6ECE7);
  static const Color backgroundGradientStart = Color(0xFFFFFDFC); // Üst Aydınlık Sıcak Porselen
  static const Color backgroundGradientEnd = Color(0xFFFDF1EB);   // Alt Sıcak Şeftali/Pudra Tint

  static const LinearGradient ambientBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundGradientStart,
      backgroundGradientEnd,
    ],
  );

  // Clay Kart Yüzeyleri (Light Pastels)
  static const Color clayRose = Color(0xFFFDE8ED);      // Romantik Pembe
  static const Color clayPeach = Color(0xFFFEE8D6);     // Şeftali / Somon
  static const Color clayLavender = Color(0xFFEDE7F6);  // Lavanta
  static const Color clayMint = Color(0xFFE8F5E9);      // Nane Yeşili
  static const Color claySky = Color(0xFFE3F2FD);       // Bebek Mavisi
  static const Color clayCream = Color(0xFFFFF8E7);     // Sıcak Krem
  static const Color clayCardSurface = Color(0xFFFFF5F5); // Temel Kart

  // Vurgu & Aksiyon Renkleri (4.5:1 kontrast garantili)
  static const Color primaryPink = Color(0xFFD85A7F);    // Ana Romantik Pembe
  static const Color primaryDark = Color(0xFF8E2A4B);    // Kontrast Başlık Rengi
  static const Color secondaryPeach = Color(0xFFE07A5F); // Şeftali Vurgu
  static const Color accentGold = Color(0xFFD4A373);     // Romantik Gold / Bal
  static const Color lavenderPurple = Color(0xFF7E57C2); // Lavanta Moru Vurgu
  static const Color medicalAlertRed = Color(0xFFD32F2F);// Acil Durum / Kırmızı Alarm
  static const Color medicalAlertBg = Color(0xFFFFEBEE); // Acil Kart Arka Planı
  static const Color successGreen = Color(0xFF388E3C);   // Tamamlandı / Başarı
  static const Color waterBlue = Color(0xFF42A5F5);      // Su Takibi
  static const Color caffeineBrown = Color(0xFF8D6E63);  // Kafein Takibi

  // Tipografi Renkleri (Yüksek okunabilirlik ve sıcak kontrast)
  static const Color textPrimary = Color(0xFF231B24);    // Derin Koyu Kömür-Mürdüm
  static const Color textSecondary = Color(0xFF635666);  // Sıcak Mürdüm Gri
  static const Color textMuted = Color(0xFF9E8F94);      // Soluk Gri

  // Klinik & Tıbbi Yeşil (Medical Records & Clinical Summaries)
  static const Color clinicalGreen = Color(0xFF2E6135);
  static const Color clinicalGreenLight = Color(0xFF4A6B50);
  static const Color clinicalGreenBg = Color(0xFFD4EBD6);

  // Ruh Hali & Duygu Durum Dereceleri (Mood Ratings 1-5)
  static const Color moodTired = Color(0xFFE57373);     // 1: Yorgun / Hassas
  static const Color moodNeutral = Color(0xFFFFB74D);   // 2: Nötr / Sakin
  static const Color moodGood = Color(0xFF81C784);      // 3: İyi / Dengeli
  static const Color moodHappy = Color(0xFF4FC3F7);     // 4: Mutlu / Enerjik
  static const Color moodPeaceful = Color(0xFFF06292);  // 5: Huzurlu / Minnettar

  // Sıvı & Kafein Vurgu Tonları
  static const Color waterBlueDark = Color(0xFF1E88E5);
  static const Color waterBlueLight = Color(0xFF64B5F6);
  static const Color caffeineAlertOrange = Color(0xFFFF7043);
  static const Color caffeineWarningAmber = Color(0xFFFFB74D);

  // Hatıra & Anı Vurgusu (Keepsake & Memory Cards)
  static const Color keepsakePurple = Color(0xFF8E24AA);
  static const Color keepsakePurpleBg = Color(0xFFFAF5FF);
  static const Color keepsakePurpleBorder = Color(0xFFCE93D8);

  // Ödül & Keşif Altın Tonları (Reward Ads & Chests)
  static const Color rewardGold = Color(0xFFE0A96D);
  static const Color rewardGoldDark = Color(0xFF8C5319);
  static const Color rewardGoldLight = Color(0xFFF9E7D0);
  static const Color rewardGoldBg = Color(0xFFC48B4B);

  // Rahim & Fetus Derin Tonlar (Ambient Sound & Fetus Preview)
  static const Color deepWombPlum = Color(0xFF1E0A12);
  static const Color deepCinematicDark = Color(0xFF1E141D);
  static const Color fetalHeartPink = Color(0xFFFF4081);

  // Liste & Durum Renkleri
  static const Color itemPackedGreenBg = Color(0xFFF2F9F2);
  static const Color amberCaution = Color(0xFFE5A100);

  // Tıbbi Ultrason & Sonografi Tonları (HD Live 4D & Doppler Telemetri)
  static const Color ultrasoundMonitorBg = Color(0xFF0C1017);
  static const Color ultrasoundBorder = Color(0xFF2A3649);
  static const Color ultrasoundGlow = Color(0xFF0F2B48);
  static const Color ultrasoundHudBg = Color(0xFF141B26);
  static const Color ultrasoundBottomBarBg = Color(0xFF0A0E14);
  static const Color ultrasoundCyan = Color(0xFF00E5FF);
  static const Color ultrasoundCyanDim = Color(0xFF90CAF9);
  static const Color ultrasoundTelemetryAmber = Color(0xFFFFD54F);
  static const Color ultrasoundSepiaDark = Color(0xFF090706);
  static const Color ultrasoundSepiaMid = Color(0xFF160F0C);
  static const Color ultrasoundSepiaLight = Color(0xFF241712);
  static const Color ultrasoundSkinWarm = Color(0xFFE0A878);
  static const Color ultrasoundSkinGlow = Color(0xFFFFE0B2);
  static const Color ultrasoundSkinBase = Color(0xFF33221C);
  static const Color ultrasoundBoneHighlight = Color(0xFFFFF3E0);
  static const Color ultrasoundBoneGlow = Color(0xFFFFE8D6);
  static const Color ultrasoundAcousticWhite = Color(0xFFFFF8F0);
  static const Color ultrasoundAnatomyTan = Color(0xFFC68B59);
  static const Color ultrasoundAnatomyBrown = Color(0xFF8D5B36);
  static const Color ultrasoundAnatomyDeep = Color(0xFF7A4A28);
  static const Color dopplerArterialRed = Color(0xFFFF1744);
  static const Color dopplerVenousBlue = Color(0xFF40C4FF);

  // Claymorphic Gölge & Işık Renkleri (Shadow Recipe Helpers)
  static const Color clayHighlightTop = Color(0xFFFFFFFF); // Üst Işık
  static const Color clayShadowDark = Color(0x28000000);   // Alt İç Gölge
  static const Color clayOuterDrop = Color(0x24C49A9E);    // Dış Yumuşak Gölge
}

