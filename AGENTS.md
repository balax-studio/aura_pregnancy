# Aura Pregnancy - Proje Geliştirme ve Tasarım Kuralları

## 1. UI ve Tasarım Tarzı Kuralı: Claymorphism

Bu projede geliştirilecek tüm kullanıcı arayüzü bileşenleri, kartlar, butonlar, form elemanları ve ekranlar istisnasız **Claymorphism** tasarım tarzına uygun olacaktır.

### Paket ve İçe Aktarma Kuralı
Flutter yerleşik `BoxDecoration` varsayılan olarak `inset` (iç gölge) desteklemediği için `flutter_inset_box_shadow` paketi kullanılır:
```dart
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
```

### A. Renk ve Tema Kuralları
- **Arka Plan (Background):** Koyu tema yasak. Yumuşak tonlu krem zemin: `Color(0xFFFDF7F4)`.
- **Yüzeyler (Card / Button):** Arka plandan bağımsız pastel renkler (ör. Şeftali: `Color(0xFFFEE6E0)`, Nane Yeşili: `Color(0xFFD4EBD6)`, Bebek Mavisi: `Color(0xFFD6E4F0)`).
- **Tipografi:** Tıknaz ve dost canlısı (`GoogleFonts.nunito` / `quicksand` / `outfit`). Yüksek kontrastlı koyu kömür metin: `Color(0xFF2D232E)`.

### B. Gölge Formülü (Shadow Recipe)
- **Dış Gölge:** `BoxShadow(color: Colors.black.withOpacity(0.18), offset: const Offset(0, 24), blurRadius: 40, inset: false)`
- **Üst İç Işık:** `BoxShadow(color: Colors.white.withOpacity(0.65), offset: const Offset(0, 8), blurRadius: 16, inset: true)`
- **Alt İç Gölge:** `BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, -8), blurRadius: 16, inset: true)`

### C. Basılma Durumu (Kural E - Pressed State)
- Dış gölgenin offset ve blur değerleri küçülür (yere yaklaşır: `offset: Offset(0, 8), blurRadius: 16`).
- İç gölgelerin derinliği artırılır (`offset: Offset(0, ±12), blurRadius: 20, inset: true`).

## 2. Tıbbi Doğruluk ve Güvenlik
- Günlük kafein sınırı: `200.0 mg`
- Acil ateş sınırı: `38.0 °C`
- IOM Standartlarına göre VKİ ve kilo artış limitleri `PregnancyMedicalSpecs` sınıfı üzerinden sabit referans alınacaktır.

## 3. Android Build & Ortam Standartları
- **JDK Konumu:** `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot` (Temurin 17).
- **Gradle & AGP:** `gradle-8.9-all.zip`, Android Gradle Plugin `8.7.0`, Kotlin `1.9.24`.
- **gradle.properties:** `org.gradle.java.home=C\:\\Program Files\\Eclipse Adoptium\\jdk-17.0.20.101-hotspot` sabit bulunmalıdır.
- **VS Code:** `.vscode/settings.json` içinde `"java.import.gradle.enabled": false` ve `"gradle.autoDetect": "off"` tanımlı kalarak IDE arka plan çakışmaları engellenir.
## 4. UI Slop Önleme Standartları (Anti-Slop Kuralları)
- **Token Zorunluluğu:** Widget dosyalarında rastgele inline `Color(0xFF...)` yazılmayacak; tüm renkler `AppColors` token'ları üzerinden alınacaktır (`AppColors.clayRose`, `AppColors.claySky`, vb.).
- **İç İçe Gölge Slop'ı (No Nested Shadow Bleed):** `ClayCard` içine konan küçük ikon ve sayaç kutularına tekrar ağır clay gölgesi verilmeyecek; temiz düz `BoxDecoration` kullanılacaktır.
- **Tipografi Standartı:** Fontlar asla `fontFamily: 'Quicksand'` gibi ham string ile çağrılmayacak; doğrudan `GoogleFonts.outfit`, `GoogleFonts.quicksand` veya `GoogleFonts.plusJakartaSans` üzerinden bağlanacaktır.
- **Alt Bar Boşluğu (Bottom Inset):** Alt gezinti çubuğunun ekran içeriğini kapatmaması için tüm kaydırılabilir listelerin sonuna `SizedBox(height: 84)` bırakılacaktır.
- **Klavye Gizlenmesi:** Form elemanları odaklandığında ve klavye açıldığında (`viewInsets.bottom > 0`), alt gezinme çubuğu formun üzerine çıkmayıp gizlenecektir.

