# Aura Pregnancy — Kapsamlı UI/UX & Tasarım Kalite İyileştirme Planı

Bu plan; `/ui-styling` ve `/ui-ux-pro-max` standartları doğrultusunda, uygulamadaki tüm "basit / şablon (slop)" görsel unsurları temizleyip, uygulamayı birinci sınıf (Apple Design Awards kalitesinde) modern bir **Claymorphism & Liquid Glass** deneyimine yükseltmeyi hedefler.

## Yapılacak Temel İyileştirmeler ve Tasarım Standartları

1. **Tipografi Bütünlüğü (Sıfır Raw TextStyle):**
   - Kod tabanında dağınık halde bulunan çıplak `TextStyle(...)` kullanımları tamamen kaldırılacak; başlıklar için geometrik ve premium `GoogleFonts.outfit`, gövde ve etiketler için yüksek okunabilirlikli `GoogleFonts.plusJakartaSans` ile standartlaştırılacak.
   - Hiyerarşi: Başlıklar (`Outfit` w800/w900, -0.4 letter-spacing), Alt Başlıklar (`Plus Jakarta Sans` w700), Gövde Metinleri (`Plus Jakarta Sans` w500/w600, 1.45 line-height).

2. **AppBar & Başlık Standartlaşması:**
   - 6 ana ekranın (Ana Sayfa, Hafta Hafta, Takip, Zaman Tüneli, Anı Günlüğü, Acil Durum) AppBar tasarımları tek bir zarif, ferah ve dokunsal dile kavuşturulacak.
   - İkon butonları sert sistem ikonları yerine yumuşak killi rozetler (Clay Pill / Capsule) içine alınacak.

3. **Renk ve Yüzey Uyumlaştırması (Harmonious Clay Palette):**
   - Sert beyaz (`Colors.white`) veya ani kontrast bozulması yaratan arka planlar; porselen sıcaklığındaki `AppColors.clayRose`, `AppColors.clayPeach`, `AppColors.clayLavender`, `AppColors.clayMint` ve `AppColors.claySky` tonlarıyla dengelenecek.
   - Gölgeler ve iç ışıklar kil dokusunu hissettiren çift katmanlı formülle pürüzsüzleştirilecek.

4. **Günlük Takip Kartları (Daily Tracker Cards):**
   - Su, kafein, adım/yürüyüş, kilo ve ilaç takip kartlarındaki sayaç butonları, ilerleme çubukları ve veri giriş alanları ultra modern, dokunsal yaylanma efektli pill butonlara dönüştürülecek.

5. **Haftalık Gelişim & Zaman Tüneli (Weekly & Timeline):**
   - Hafta seçim şeridi (`weekly_timeline_strip`), tıbbi kontrol listesi (`medical_tests_checklist_card`) ve zaman tüneli kartlarındaki görsel dağınıklık giderilecek; mikro rozetler ve akıcı geçişlerle zenginleştirilecek.

6. **Anı Günlüğü & Acil Durum Ekranları (Journal & Emergency):**
   - Anı kartları, sesli mektup oynatıcısı ve acil durum doktor arama kartı birinci sınıf sağlık & lüks yaşam tarzı uygulaması seviyesine çıkarılacak.

---

## Değiştirilecek Dosyalar

### 1. Tasarım Sistemi ve Çekirdek Bileşenler
- `[MODIFY]` `lib/core/theme/clay_theme.dart`: Tipografi, kart kenar yarıçapları, gölge ve iç ışık derinliklerinin rafine edilmesi.
- `[MODIFY]` `lib/views/widgets/clay_input.dart`: Form giriş alanlarında tipografi ve odaklanma kenarlığı iyileştirmesi.

### 2. Ana Navigasyon ve Ekranlar
- `[MODIFY]` `lib/views/dashboard/dashboard_screen.dart`: Dashboard başlıkları, 3D fetus kartı, trimester ve haftalık test kartlarındaki raw fontların temizlenmesi ve görsel hiyerarşinin parlatılması.
- `[MODIFY]` `lib/views/weekly_panel/weekly_panel_screen.dart`: AppBar, durum rozetleri ve hafta detay kartlarının premium hale getirilmesi.
- `[MODIFY]` `lib/views/weekly_panel/widgets/weekly_timeline_strip.dart`: Hafta seçici kapsüllerin modernleştirilmesi.
- `[MODIFY]` `lib/views/weekly_panel/widgets/medical_tests_checklist_card.dart`: Tıbbi kontrol listesi kartının modernleştirilmesi.
- `[MODIFY]` `lib/views/daily_tracker/daily_tracker_screen.dart`: AppBar ve genel boşluk hiyerarşisi.
- `[MODIFY]` `lib/views/daily_tracker/widgets/water_tracker_card.dart`: Su sayacı kapsül ve ikon tasarımı.
- `[MODIFY]` `lib/views/daily_tracker/widgets/caffeine_tracker_card.dart`: Kafein göstergesi ve uyarı tonları.
- `[MODIFY]` `lib/views/daily_tracker/widgets/walking_tracker_card.dart`: Adım ve kalori kartı tipografisi.
- `[MODIFY]` `lib/views/timeline/timeline_screen.dart`: Zaman tüneli istatistik kartları, filtre çipleri ve akış kartları.
- `[MODIFY]` `lib/views/journal/journal_screen.dart`: Anı günlüğü üst bannerı, boş durum illüstrasyonu ve butonları.
- `[MODIFY]` `lib/views/emergency/emergency_screen.dart`: Acil durum ekranı tipografisi ve doktor arama aksiyon butonları.

---

## Doğrulama Planı

### Otomatik Testler
- `flutter test`: Tüm 67 otomatik testin hatasız geçmesi.
- `flutter analyze`: Kod tabanında 0 hata ve uyarı doğrulaması.

### Manuel Doğrulama
- Ekran geçişleri, font renderlama ve renk harmonisinin görsel olarak kontrol edilmesi.
