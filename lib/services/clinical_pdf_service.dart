import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/profile_model.dart';
import '../models/emergency_card_model.dart';

/// Aura Pregnancy - Klinik Hekim Raporu PDF Üretim ve Paylaşım Servisi
class ClinicalPdfService {
  ClinicalPdfService._internal();
  static final ClinicalPdfService instance = ClinicalPdfService._internal();

  /// Şık ve kadınlara özel pastel tonlarda tek sayfalık A4 hekim raporu PDF'i üretir
  Future<Uint8List> generateClinicalPdf({
    required ProfileModel? profile,
    required EmergencyCardModel? emergencyCard,
  }) async {
    final pdf = pw.Document(
      title: 'Aura Pregnancy - Klinik Hekim Özeti',
      author: 'Aura Pregnancy',
    );

    // Font yükleme (Fallback ile çevrimdışı güvenliği)
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
          .replaceAll('ğ', 'g')
          .replaceAll('•', '-');
    }

    // Renk Paleti (Aura Pastel Teması)
    const primaryPink = PdfColor.fromInt(0xFFD9778F);
    const darkCharcoal = PdfColor.fromInt(0xFF2D232E);
    const slateMuted = PdfColor.fromInt(0xFF7A6E78);
    const surfacePeach = PdfColor.fromInt(0xFFFFF3F0);
    const borderPeach = PdfColor.fromInt(0xFFFCDFD7);
    const surfaceMint = PdfColor.fromInt(0xFFF1F8F2);
    const borderMint = PdfColor.fromInt(0xFFD5E8D8);
    const surfaceWhite = PdfColors.white;

    final todayStr = DateTime.now().toLocal().toString().split(' ')[0];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. ÜST BAŞLIK VE TARİH
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: surfacePeach,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: borderPeach, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              'Aura Pregnancy',
                              style: const pw.TextStyle(
                                color: primaryPink,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: primaryPink,
                                borderRadius: pw.BorderRadius.circular(6),
                              ),
                              child: pw.Text(
                                s('Klinik Özet'),
                                style: const pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          s('Hekim Kontrolü & Rutin Gebelik Muayene Formu'),
                          style: const pw.TextStyle(color: slateMuted, fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          s('Rapor Tarihi'),
                          style: const pw.TextStyle(color: slateMuted, fontSize: 9),
                        ),
                        pw.Text(
                          todayStr,
                          style: const pw.TextStyle(
                            color: darkCharcoal,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // 2. ANNE & BEBEK PROFİL KARTI
              _buildSectionHeader(s('GENEL GEBELİK VE ANNE-BEBEK BİLGİLERİ'), primaryPink),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: surfaceWhite,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderPeach, width: 0.8),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow(s('Anne Adayı'), s(profile?.momName ?? emergencyCard?.patientName ?? 'Belirtilmedi')),
                          pw.SizedBox(height: 6),
                          _buildFieldRow(s('Bebek İsmi'), s(profile?.babyName ?? 'Bebeğimiz')),
                          pw.SizedBox(height: 6),
                          _buildFieldRow(
                            s('Cinsiyet'),
                            s(profile?.babyGender == 'girl'
                                ? 'Kız'
                                : profile?.babyGender == 'boy'
                                    ? 'Erkek'
                                    : 'Belirtilmedi'),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow(s('Gebelik Haftası'), s('${profile?.currentWeek ?? 12}. Hafta')),
                          pw.SizedBox(height: 6),
                          _buildFieldRow(s('Son Adet Tarihi (SAT)'), s(profile?.lmpDate ?? emergencyCard?.lmpDate ?? '-')),
                          pw.SizedBox(height: 6),
                          _buildFieldRow(s('Tahmini Doğum (EDD)'), s(profile?.dueDate ?? emergencyCard?.dueDate ?? '-')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 3. VİTAL VE SAĞLIK GÖSTERGELERİ
              _buildSectionHeader(s('VİTAL BULGULAR VE FİZİKSEL TAKİP'), const PdfColor.fromInt(0xFF2E6135)),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: surfaceMint,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderMint, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricBox(s('Kan Grubu'), s(emergencyCard?.bloodType ?? 'Belirtilmedi'), darkCharcoal),
                    _buildMetricBox(s('Başlangıç Kilosu'), s('${profile?.prePregnancyWeight ?? "-"} kg'), darkCharcoal),
                    _buildMetricBox(s('Boy'), s('${profile?.height ?? "-"} cm'), darkCharcoal),
                    _buildMetricBox(s('VKİ'), s('${profile?.vki ?? "-"}'), const PdfColor.fromInt(0xFF2E6135)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 4. HEKİM, HASTANE VE RİSK/ALERJİ KARTI
              _buildSectionHeader(s('KLİNİK İLETİŞİM VE TIBBİ UYARILAR'), primaryPink),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: surfaceWhite,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: borderPeach, width: 0.8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildFieldRow(
                            s('Takip Eden Hekim'),
                            s(emergencyCard?.doctorName.isNotEmpty == true
                                ? '${emergencyCard!.doctorName} (${emergencyCard.doctorPhone})'
                                : 'Belirtilmedi'),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: _buildFieldRow(
                            s('Hastane / Klinik'),
                            s(emergencyCard?.hospitalName.isNotEmpty == true ? emergencyCard!.hospitalName : 'Belirtilmedi'),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildFieldRow(
                            s('Bilinen Alerjiler'),
                            s(emergencyCard?.allergies.isNotEmpty == true ? emergencyCard!.allergies : 'İlaç alerjisi bildirilmedi'),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: _buildFieldRow(
                            s('Kronik Durumlar'),
                            s(emergencyCard?.chronicDiseases.isNotEmpty == true ? emergencyCard!.chronicDiseases : 'Kronik durum bildirilmedi'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 5. HEKİM GÖZLEM, MUAYENE VE ULTRASON NOTLARI
              _buildSectionHeader(s('HEKİM MUAYENE VE KONTROL NOTLARI (KLİNİK KULLANIM)'), darkCharcoal),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: surfaceWhite,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFFDCD6D8), width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(s('Tansiyon (TA): _____ / _____ mmHg'), style: const pw.TextStyle(color: darkCharcoal, fontSize: 9)),
                        pw.Text(s('Güncel Kilo: _____ kg'), style: const pw.TextStyle(color: darkCharcoal, fontSize: 9)),
                        pw.Text(s('FKA: _____ bpm'), style: const pw.TextStyle(color: darkCharcoal, fontSize: 9)),
                        pw.Text(s('Ödem: Yok / Az / Var'), style: const pw.TextStyle(color: darkCharcoal, fontSize: 9)),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(s('Muayene Bulguları, Fetal Gelişim & Reçete Notları:'), style: const pw.TextStyle(color: slateMuted, fontSize: 8.5)),
                    pw.SizedBox(height: 6),
                    pw.Divider(color: const PdfColor.fromInt(0xFFE8E2E4), thickness: 0.8),
                    pw.SizedBox(height: 14),
                    pw.Divider(color: const PdfColor.fromInt(0xFFE8E2E4), thickness: 0.8),
                    pw.SizedBox(height: 14),
                    pw.Divider(color: const PdfColor.fromInt(0xFFE8E2E4), thickness: 0.8),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(s('Sonraki Randevu: ___ / ___ / 2026'), style: const pw.TextStyle(color: slateMuted, fontSize: 9)),
                        pw.Text(s('Hekim Kaşe / İmza: ________________________'), style: const pw.TextStyle(color: darkCharcoal, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // 6. ALT BİLGİ VE ŞEFKATLİ DİLEK
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: borderPeach, width: 0.8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      s('Aura Pregnancy ile sevgiyle hazırlandı • Sağlıklı ve huzurlu bir gebelik dileriz.'),
                      style: const pw.TextStyle(color: slateMuted, fontSize: 8),
                    ),
                    pw.Text(
                      'aurapregnancy.app',
                      style: const pw.TextStyle(color: primaryPink, fontSize: 8),
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

  /// PDF'i oluşturur ve sistem paylaşım / yazdırma / dosyalara kaydetme sayfasını açar
  Future<void> generateAndShareReport({
    required ProfileModel? profile,
    required EmergencyCardModel? emergencyCard,
  }) async {
    final pdfBytes = await generateClinicalPdf(
      profile: profile,
      emergencyCard: emergencyCard,
    );

    final momNameClean = (profile?.momName ?? 'Anne').replaceAll(RegExp(r'\s+'), '_');
    final fileName = 'Aura_Klinik_Hekim_Ozeti_${momNameClean}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }

  static pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 2),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildFieldRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 95,
          child: pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColor.fromInt(0xFF7A6E78), fontSize: 8.5),
          ),
        ),
        pw.Text(': ', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF7A6E78), fontSize: 8.5)),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              color: PdfColor.fromInt(0xFF2D232E),
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMetricBox(String label, String value, PdfColor valueColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFD5E8D8), width: 0.8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColor.fromInt(0xFF7A6E78), fontSize: 8),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: valueColor,
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
