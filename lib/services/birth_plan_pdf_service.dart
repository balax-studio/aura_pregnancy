import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/birth_plan_model.dart';
import '../models/profile_model.dart';

/// Aura Pregnancy - Altın Mühürlü Kişisel Doğum Tercihleri PDF Servisi
class BirthPlanPdfService {
  BirthPlanPdfService._internal();
  static final BirthPlanPdfService instance = BirthPlanPdfService._internal();

  Future<Uint8List> generateBirthPlanPdf({
    required ProfileModel? profile,
    required BirthPlanModel plan,
  }) async {
    final pdf = pw.Document(
      title: 'Aura Pregnancy - Kişisel Doğum Tercihleri Planı',
      author: 'Aura Pregnancy',
    );

    pw.Font fontRegular;
    pw.Font fontBold;
    bool isFallback = false;
    try {
      fontRegular = await PdfGoogleFonts.nunitoRegular();
      fontBold = await PdfGoogleFonts.nunitoBold();
    } catch (_) {
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
      isFallback = true;
    }

    String s(String text) {
      if (!isFallback) return text;
      return text
          .replaceAll('İ', 'I')
          .replaceAll('ı', 'i')
          .replaceAll('Ş', 'S')
          .replaceAll('ş', 's')
          .replaceAll('Ğ', 'G')
          .replaceAll('ğ', 'g');
    }

    const primaryRose = PdfColor.fromInt(0xFFD85A7F);
    const accentGold = PdfColor.fromInt(0xFFB8860B);
    const darkCharcoal = PdfColor.fromInt(0xFF231B24);
    const slateMuted = PdfColor.fromInt(0xFF635666);
    const surfacePeach = PdfColor.fromInt(0xFFFFF8F6);
    const borderPeach = PdfColor.fromInt(0xFFF9DDD4);

    final todayStr = DateTime.now().toLocal().toString().split(' ')[0];
    final momName = profile?.momName ?? 'Anne Adayı';
    final partnerName = profile?.partnerName ?? 'Eş / Refakatçi';
    final babyName = profile?.babyDisplayName ?? 'Bebeğimiz';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Üst Başlık ve Altın Mühür Rozeti
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: surfacePeach,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: borderPeach, width: 1.2),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 48,
                      height: 48,
                      decoration: const pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: accentGold,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          s('AURA'),
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            s('KİŞİSEL DOĞUM TERCİHLERİ VE GÜVENLİK PLANI'),
                            style: const pw.TextStyle(
                              color: darkCharcoal,
                              fontSize: 13.5,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            s('Hekim ve Ebe Ekibine Bilgilendirme Notudur • Düzenleme Tarihi: $todayStr'),
                            style: const pw.TextStyle(color: slateMuted, fontSize: 8.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // Anne ve Aile Bilgi Şeridi
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildInfoCard('Anne Adayı', s(momName), 'Gebelik: ${profile?.currentWeek ?? "-"}. Hafta'),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildInfoCard('Eş / Refakatçi', s(partnerName), 'Hedef Doğum: ${profile?.dueDate ?? "-"}'),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _buildInfoCard('Bebek Hitabı', s(babyName), 'Cinsiyet: ${profile?.babyGender ?? "Sürpriz"}'),
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // 1. Ortam & Ruh Hali
              _buildSectionTitle(s('1. DOĞUM ODASI ORTAMI VE DESTEK'), primaryRose),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildCheckItem('Loş ve Sakin Işıklandırma', plan.dimLights)),
                  pw.Expanded(child: _buildCheckItem('Kişisel Fon Müziği / Ninni', plan.ambientMusic)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildCheckItem('Aromaterapi / Rahatlatıcı Koku', plan.aromatherapy)),
                  pw.Expanded(child: _buildCheckItem('Gereksiz Personel Girişinin Kısıtlanması', plan.quietEnvironment)),
                ],
              ),
              pw.SizedBox(height: 10),

              // 2. Ağrı Yönetimi
              _buildSectionTitle(s('2. DOĞAL AKIŞ VE AĞRI YÖNETİMİ'), primaryRose),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildCheckItem('Epidural Analjezi Talebi', plan.epiduralPreferred)),
                  pw.Expanded(child: _buildCheckItem('Doğal Nefes & Hareket Serbestisi', plan.naturalPainRelief)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildCheckItem('Pilates Topu Kullanımı', plan.birthingBall)),
                  pw.Expanded(child: _buildCheckItem('Ilık Duş / Su Desteği', plan.warmWaterShower)),
                ],
              ),
              pw.SizedBox(height: 10),

              // 3. Doğum Anı & Müdahaleler
              _buildSectionTitle(s('3. DOĞUM ANI VE TIBBİ İLETİŞİM'), primaryRose),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildCheckItem('Müdahaleleri Önceden Bilgilendirme', plan.discussBeforeIntervention)),
                  pw.Expanded(child: _buildCheckItem('Spontan ve Zorlamasız Ikınma', plan.spontaneousPushing)),
                ],
              ),
              pw.SizedBox(height: 10),

              // 4. İlk Dakikalar (Golden Hour)
              _buildSectionTitle(s('4. İLK DAKİKALAR (ALTIN SAAT) VE YENİDOĞAN BAKIMI'), primaryRose),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildCheckItem('Kordonun Geç Klemplenmesi (>=60 sn)', plan.delayedCordClamping)),
                  pw.Expanded(child: _buildCheckItem('Babanın Kordonu Kesmesi', plan.partnerCutsCord)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildCheckItem('Anında Kesintisiz Ten Tene Temas', plan.immediateSkinToSkin)),
                  pw.Expanded(child: _buildCheckItem('İlk Bebek Banyosunun 24 Saat Ertelenmesi', plan.delayNewbornBath24h)),
                ],
              ),
              pw.SizedBox(height: 12),

              // Özel Dilekler ve Hekim Notu
              if (plan.specialWishes.isNotEmpty) ...[
                _buildSectionTitle(s('ANNE VE BABANIN ÖZEL DİLEKLERİ'), darkCharcoal),
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Text(
                    s(plan.specialWishes),
                    style: const pw.TextStyle(color: darkCharcoal, fontSize: 9),
                  ),
                ),
                pw.SizedBox(height: 14),
              ],

              pw.Spacer(),

              // Alt İmza ve Kaşe Alanı
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(s('Anne & Baba Adayı İmzası'), style: const pw.TextStyle(color: slateMuted, fontSize: 8)),
                        pw.SizedBox(height: 24),
                        pw.Text(s('İmza: _______________________'), style: const pw.TextStyle(color: darkCharcoal, fontSize: 8.5)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(s('Takip Eden Kadın Doğum Uzmanı / Ebe'), style: const pw.TextStyle(color: slateMuted, fontSize: 8)),
                        pw.SizedBox(height: 24),
                        pw.Text(s('Kaşe & İmza: _______________________'), style: const pw.TextStyle(color: darkCharcoal, fontSize: 8.5)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> generateAndShareBirthPlan({
    required ProfileModel? profile,
    required BirthPlanModel plan,
  }) async {
    final pdfBytes = await generateBirthPlanPdf(profile: profile, plan: plan);
    final momNameClean = (profile?.momName ?? 'Anne').replaceAll(RegExp(r'\s+'), '_');
    final fileName = 'Aura_Dogum_Plani_${momNameClean}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  static pw.Widget _buildInfoCard(String title, String main, String sub) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9F7F5),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFECE5DE), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(color: PdfColor.fromInt(0xFF635666), fontSize: 7.5)),
          pw.SizedBox(height: 2),
          pw.Text(main, style: const pw.TextStyle(color: PdfColor.fromInt(0xFF231B24), fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 1),
          pw.Text(sub, style: const pw.TextStyle(color: PdfColor.fromInt(0xFFD85A7F), fontSize: 7.5)),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String text, PdfColor color) {
    return pw.Text(
      text,
      style: pw.TextStyle(color: color, fontSize: 9.5, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _buildCheckItem(String label, bool isChecked) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: isChecked ? const PdfColor.fromInt(0xFF388E3C) : PdfColors.white,
              borderRadius: pw.BorderRadius.circular(3),
              border: pw.Border.all(
                color: isChecked ? const PdfColor.fromInt(0xFF388E3C) : const PdfColor.fromInt(0xFFBDBDBD),
                width: 1,
              ),
            ),
            child: isChecked
                ? pw.Center(
                    child: pw.Text('V', style: const pw.TextStyle(color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  )
                : null,
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: isChecked ? const PdfColor.fromInt(0xFF231B24) : const PdfColor.fromInt(0xFF757575),
                fontSize: 8.5,
                fontWeight: isChecked ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
