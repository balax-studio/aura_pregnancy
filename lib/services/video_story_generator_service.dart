import '../services/database_helper.dart';

/// Video Karesi (Story Frame) Modeli
class VideoStoryFrame {
  final int week;
  final String date;
  final String title;
  final String subtitle;
  final String photoPath;
  final String? audioPath;
  final String quote;

  const VideoStoryFrame({
    required this.week,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.photoPath,
    this.audioPath,
    required this.quote,
  });
}

/// Aura Pregnancy - Time-lapse Video ve Hikaye Oluşturucu Servisi
class VideoStoryGeneratorService {
  VideoStoryGeneratorService._internal();
  static final VideoStoryGeneratorService instance =
      VideoStoryGeneratorService._internal();

  /// Veritabanındaki tüm anı ve fotoğraflardan Time-lapse hikaye karelerini derler
  Future<List<VideoStoryFrame>> generateStoryFrames() async {
    final profile = await DatabaseHelper.instance.getProfile();
    final diaries = await DatabaseHelper.instance.getAllDiaries();

    // Fotoğrafı olan veya romantik highlight olarak işaretlenen anıları filtrele
    final visualDiaries = diaries
        .where((d) =>
            (d.photoPath != null && d.photoPath!.isNotEmpty) ||
            d.isRomanticHighlight ||
            (d.noteText != null && d.noteText!.isNotEmpty))
        .toList();

    // Haftaya göre kronolojik sırala
    visualDiaries.sort((a, b) => a.pregnancyWeek.compareTo(b.pregnancyWeek));

    final List<VideoStoryFrame> frames = [];

    // Eğer hiç anı yoksa varsayılan trimester dönüm noktalarından bir demo hikayesi oluştur
    if (visualDiaries.isEmpty) {
      final currentWeek = profile?.currentPregnancyWeek ?? 12;
      return [
        const VideoStoryFrame(
          week: 4,
          date: '2026-06-05',
          title: '4. Hafta • Yaşamın Başlangıcı',
          subtitle: 'Minik bir mucize aramıza katıldı.',
          photoPath: 'assets/images/aura_logo.png',
          quote: 'İlk andan beri seni büyük bir sevgiyle bekliyoruz...',
        ),
        VideoStoryFrame(
          week: currentWeek,
          date: '2026-08-29',
          title: '$currentWeek. Hafta • Birlikte Büyüyoruz',
          subtitle: 'Her kalp atışında aşkımız büyüyor.',
          photoPath: 'assets/images/sample_ultrasound.png',
          quote: 'Seninle geçen her gün hayatımızın en güzel hediyesi.',
        ),
      ];
    }

    final babyName = profile?.babyDisplayName ?? 'Bebeğimiz';

    for (final diary in visualDiaries) {
      final note = (diary.noteText != null && diary.noteText!.isNotEmpty)
          ? diary.noteText!
          : '$babyName ile unutulmaz bir hatıra.';

      frames.add(
        VideoStoryFrame(
          week: diary.pregnancyWeek,
          date: diary.date,
          title: '${diary.pregnancyWeek}. Hafta • $babyName',
          subtitle: note,
          photoPath: (diary.photoPath != null && diary.photoPath!.isNotEmpty)
              ? diary.photoPath!
              : 'assets/images/sample_ultrasound.png',
          audioPath: diary.audioPath,
          quote: diary.isRomanticHighlight
              ? 'Kalbimizin en özel anı • $babyName'
              : '$babyName için sevgiyle...',
        ),
      );
    }

    return frames;
  }
}
