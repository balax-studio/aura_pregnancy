/// Aura Pregnancy — Bebek Perspektifli Bildirim Mesaj Kütüphanesi
/// Tüm mesajlar sanki bebek yazıyormuş gibi sıcak, samimi ve tatlı bir dille yazılmıştır.
/// TR + EN çift dil desteği mevcuttur.
library notification_messages;

class NotificationMessages {
  // ────────────────────────────────────────────────────────────────────
  // Kategori 1 — Haftalık Bebek Gelişimi (Hafta bazlı, gerçek tıbbi bilgiler)
  // ────────────────────────────────────────────────────────────────────

  static const Map<int, NotifWeeklyMessage> weeklyDevelopmentTr = {
    5:  NotifWeeklyMessage(title: 'Merhaba anneciğim! 🐣', body: '5. haftayım! Kalbim şimdi atıyor — bip bip! Beni hissediyor musun? 💗'),
    6:  NotifWeeklyMessage(title: 'Anneciğim, büyüyorum! 🌱', body: '6. haftada beyin ve omurilik oluşmaya başladı. Çok çalışıyorum! 🧠'),
    7:  NotifWeeklyMessage(title: 'Kollarım var şimdi! 👋', body: '7. haftada küçük kolcuklar ve bacaklar beliriyor. Seninle dans etmek istiyorum! 💃'),
    8:  NotifWeeklyMessage(title: 'Fasulye büyüklüğündeyim! 🫘', body: '8. haftada tüm organlarım şekillenmeye başladı. Artık bebek gibiyim! 🍀'),
    9:  NotifWeeklyMessage(title: 'Kiraz tomatiğim! 🍅', body: '9. haftada kaslarım hareket etmeye başlıyor ama sen henüz hissedemiyorsun 😄'),
    10: NotifWeeklyMessage(title: 'Çilek büyüklüğündeyim! 🍓', body: '10. haftada parmak izlerim oluşuyor. Ben artık tamamen kendimim! ✨'),
    11: NotifWeeklyMessage(title: 'Ananas dilimi kadarım! 🍋', body: '11. haftada kıl folikülleri çıkıyor. Tüylü olacak mıyım acaba? 🤭'),
    12: NotifWeeklyMessage(title: 'Erik büyüklüğündeyim! 🫐', body: '12. haftada reflekslerim başladı. Uyarınca hareket ediyorum! 🌟'),
    13: NotifWeeklyMessage(title: 'Limon kadar oldum! 🍋', body: '1. trimesteri bitiriyorum! Artık daha güvenli sularda yüzüyorum 🏊'),
    14: NotifWeeklyMessage(title: 'Şeftali büyüklüğündeyim! 🍑', body: '14. haftada yüzüm şekilleniyor. Sana benzeyecek miyim? 😊'),
    15: NotifWeeklyMessage(title: 'Elma kadar büyüdüm! 🍎', body: '15. haftada ışığa tepki veriyorum! Göz kapaklarım kapalı olsa da hissediyorum 👁️'),
    16: NotifWeeklyMessage(title: 'Avokado büyüklüğündeyim! 🥑', body: '16. haftada kemiklerim sertleşiyor. Güçleniyorum anneciğim! 💪'),
    17: NotifWeeklyMessage(title: 'Turp büyüklüğündeyim! 🥕', body: '17. haftada yağ depoluyorum. Kış hazırlığı yapıyorum hehe! 😄'),
    18: NotifWeeklyMessage(title: 'Tatlı patates kadarım! 🍠', body: '18. haftada sesler duyuyorum! Senin sesini duymak çok güzel 🎵'),
    19: NotifWeeklyMessage(title: 'Mango büyüklüğündeyim! 🥭', body: '19. haftada verniks tabakası oluşuyor — derimi koruyan özel kremim! 🧴'),
    20: NotifWeeklyMessage(title: 'Yarı yola geldik! 🎉', body: '20. haftada muz büyüklüğündeyim ve tepkiler veriyorum. Yarı yola geldik anneciğim! 🍌'),
    21: NotifWeeklyMessage(title: 'Havuç kadar oldum! 🥕', body: '21. haftada kaşlar ve kirpikler beliriyor. Güzel gözlerim olacak sanırım 👁️✨'),
    22: NotifWeeklyMessage(title: 'Hindistancevizi büyüklüğündeyim! 🥥', body: '22. haftada uyku-uyanıklık döngüm başladı. Seninle aynı ritimde uyuyorum! 😴'),
    23: NotifWeeklyMessage(title: 'Patlıcan kadar büyüdüm! 🍆', body: '23. haftada kan damarlarım görünebilir. Renk gelsin anneciğim! 🌸'),
    24: NotifWeeklyMessage(title: 'Mısır koçanı büyüklüğündeyim! 🌽', body: '24. haftada akciğerlerim gelişiyor. Dünyada nefes almaya hazırlanıyorum! 🌬️'),
    25: NotifWeeklyMessage(title: 'Roka demetiyim! 🥬', body: '25. haftada saçlarım çıkmaya başlıyor. Güzel saçlarım olacak mı sence? 💇'),
    26: NotifWeeklyMessage(title: 'Marul büyüklüğündeyim! 🥗', body: '26. haftada gözlerim açılıp kapanabiliyor. İlk göz kırpışım! 😉'),
    27: NotifWeeklyMessage(title: 'Karnabahar kadarım! 🥦', body: '27. haftada beyin dalgalarım ölçülebilir! Zeki biri olacağım sanırım 🧠✨'),
    28: NotifWeeklyMessage(title: '3. trimestere girdik! 🎀', body: '28. haftada patlıcan büyüklüğündeyim. Son düzlüğe girdik anneciğim! 🏁'),
    29: NotifWeeklyMessage(title: 'Acorn kabağı kadarım! 🎃', body: '29. haftada kemiklerim tamamen sertleşiyor. Güçlü olacağım! 💪'),
    30: NotifWeeklyMessage(title: 'Lahana büyüklüğündeyim! 🥬', body: '30. haftada 3 milyar beyin hücresi! Çok akıllı olacağım anneciğim 🧠'),
    31: NotifWeeklyMessage(title: 'Hindiba kadar oldum! 🌿', body: '31. haftada tüm duyu organlarım çalışıyor. Dünya için hazırlanıyorum! 🌍'),
    32: NotifWeeklyMessage(title: 'Kavun büyüklüğündeyim! 🍈', body: '32. haftada tırnaklar tamamlandı. Manikür zamanı! 💅 (Şaka tabii 😄)'),
    33: NotifWeeklyMessage(title: 'Ananas kadar büyüdüm! 🍍', body: '33. haftada kemikler sertleşti ama kafatası hâlâ esnek — akıllıca değil mi? 🧠'),
    34: NotifWeeklyMessage(title: 'Kabak büyüklüğündeyim! 🎃', body: '34. haftada doğuma hazırlanıyorum. Aşağıya dönmeye çalışıyorum anneciğim! ⬇️'),
    35: NotifWeeklyMessage(title: 'Bal kabağı kadarım! 🎃', body: '35. haftada beyin ve akciğerler neredeyse hazır. Az kaldı anneciğim! 🌟'),
    36: NotifWeeklyMessage(title: 'Papaya büyüklüğündeyim! 🍈', body: '36. haftada verniks azalıyor. Neredeyse hazırım! Bekle beni anneciğim 💗'),
    37: NotifWeeklyMessage(title: 'Sağlıklıyım ve hazırım! ✅', body: '37. haftada erken dönem miadında doğum! Birkaç haftaya kadar görüşeceğiz 🌸'),
    38: NotifWeeklyMessage(title: 'Az kaldı anneciğim! ⏰', body: '38. haftada beyin aktivitem artıyor. Düşünmeye hazırlanıyorum! Bekle beni 🌟'),
    39: NotifWeeklyMessage(title: 'Neredeyse hazırım! 🌈', body: '39. haftada tam miadındayım. Hazır olduğumda sana haber vereceğim! 💗'),
    40: NotifWeeklyMessage(title: 'Doğum zamanı yaklaşıyor! 🎉', body: '40. haftaya geldik anneciğim! Çok yakında yüz yüze olacağız 🤱💗'),
  };

  static const Map<int, NotifWeeklyMessage> weeklyDevelopmentEn = {
    5:  NotifWeeklyMessage(title: 'Hello mommy! 🐣', body: 'Week 5! My heart is beating now — beep beep! Can you feel me? 💗'),
    8:  NotifWeeklyMessage(title: 'Kidney bean sized! 🫘', body: 'Week 8: all my organs are starting to form. I look like a baby! 🍀'),
    10: NotifWeeklyMessage(title: 'Strawberry sized! 🍓', body: 'Week 10: my fingerprints are forming. I am uniquely me! ✨'),
    13: NotifWeeklyMessage(title: 'Lemon sized! 🍋', body: 'Finishing first trimester! Safer waters from here 🏊'),
    16: NotifWeeklyMessage(title: 'Avocado sized! 🥑', body: 'Week 16: my bones are hardening. Getting stronger mommy! 💪'),
    20: NotifWeeklyMessage(title: 'Halfway there! 🎉', body: 'Week 20: banana sized and responding! Halfway there mommy! 🍌'),
    24: NotifWeeklyMessage(title: 'Corn on the cob! 🌽', body: 'Week 24: my lungs are developing. Preparing to breathe! 🌬️'),
    28: NotifWeeklyMessage(title: 'Third trimester! 🎀', body: 'Week 28: home stretch mommy! 🏁'),
    32: NotifWeeklyMessage(title: 'Cantaloupe sized! 🍈', body: 'Week 32: my fingernails are done. Getting ready! 💅'),
    36: NotifWeeklyMessage(title: 'Papaya sized! 🍈', body: 'Week 36: almost ready! Wait for me mommy 💗'),
    40: NotifWeeklyMessage(title: 'Almost time! 🎉', body: 'Week 40 mommy! We will be face to face very soon 🤱💗'),
  };

  // ────────────────────────────────────────────────────────────────────
  // Kategori 2 — Günlük Anı Hatırlatıcısı
  // ────────────────────────────────────────────────────────────────────

  static const List<NotifSimpleMessage> dailyJournalTr = [
    NotifSimpleMessage(title: 'Anneciğim, bugünü unutma! 📖', body: 'Bu gün geçti ama anılar kalmaya devam eder. Bugünü birlikte kaydedelim 💕'),
    NotifSimpleMessage(title: 'Seni özlüyorum anneciğim! 💗', body: 'Bugün nasıl hissettin? Ben seninle her şeyi hissediyorum. Yaz, anlat 📝'),
    NotifSimpleMessage(title: 'Bugünün anısı kaybolmasın! ✨', body: 'Benim için bugünü not alsana — büyüyünce okumak isteyeceğim 🌸'),
    NotifSimpleMessage(title: 'Akşam oldu anneciğim 🌙', body: 'Gün bitmeden bir şeyler kaydet. Bir gün bu anları çok özleyeceksin 💕'),
    NotifSimpleMessage(title: 'Günlüğümüzü açalım mı? 📔', body: 'Sen yazarsın, ben hissederim. Bugün nasıl bir gündü? ✨'),
    NotifSimpleMessage(title: 'Bu an özel anneciğim! 🌟', body: 'Her gün büyüyor ve değişiyorum. Bugünü saklamak ister misin? 💗'),
    NotifSimpleMessage(title: 'Birlikte anı biriktireceğiz! 🎀', body: 'Bugün küçük bir not bile yeterli. Yazıyor musun anneciğim? 📝'),
  ];

  static const List<NotifSimpleMessage> dailyJournalEn = [
    NotifSimpleMessage(title: 'Don\'t forget today mommy! 📖', body: 'This day will pass but memories stay. Let\'s capture it together 💕'),
    NotifSimpleMessage(title: 'I miss you mommy! 💗', body: 'How did you feel today? I feel everything with you. Write it down 📝'),
    NotifSimpleMessage(title: 'Don\'t let today\'s memory fade! ✨', body: 'Write it for me — I\'ll want to read it when I grow up 🌸'),
    NotifSimpleMessage(title: 'Evening is here mommy 🌙', body: 'Before the day ends, save something. You\'ll treasure these moments 💕'),
    NotifSimpleMessage(title: 'Shall we open our diary? 📔', body: 'You write, I feel. How was today? ✨'),
    NotifSimpleMessage(title: 'This moment is special mommy! 🌟', body: 'I grow and change every day. Would you like to save today? 💗'),
  ];

  // ────────────────────────────────────────────────────────────────────
  // Kategori 3 — Vitamin / Su Hatırlatıcısı
  // ────────────────────────────────────────────────────────────────────

  static const List<NotifSimpleMessage> dailyVitaminTr = [
    NotifSimpleMessage(title: 'Günaydın anneciğim! 🌸', body: 'Benim için bugün vitaminini ve 8 bardak suyu unutma — ben büyüyorum! 💊'),
    NotifSimpleMessage(title: 'Folik asit aldın mı? 💊', body: 'Beyin gelişimim için çok önemli! Teşekkürler anneciğim 🥰'),
    NotifSimpleMessage(title: 'Ben susamışım anneciğim! 💧', body: 'Sabah oldu! Sen de en az 8 bardak su içmeyi unutma lütfen 🌊'),
    NotifSimpleMessage(title: 'Sağlıklı kalmalıyız! 🌿', body: 'Demir, kalsiyum ve folik asit — bunlar bizim süper gıdalarımız! 💪'),
    NotifSimpleMessage(title: 'Vitamin saati anneciğim! ⏰', body: 'Her gün düzenli almak çok önemli. Ben de düzenli büyüyorum! 📈'),
  ];

  static const List<NotifSimpleMessage> dailyVitaminEn = [
    NotifSimpleMessage(title: 'Good morning mommy! 🌸', body: 'Don\'t forget vitamins and 8 glasses of water — I\'m growing! 💊'),
    NotifSimpleMessage(title: 'Did you take folic acid? 💊', body: 'So important for my brain! Thank you mommy 🥰'),
    NotifSimpleMessage(title: 'I am thirsty mommy! 💧', body: 'Morning! Please drink at least 8 glasses of water today 🌊'),
    NotifSimpleMessage(title: 'Stay healthy! 🌿', body: 'Iron, calcium and folic acid — our superfoods! 💪'),
  ];

  // ────────────────────────────────────────────────────────────────────
  // Kategori 4 — Re-Engagement / Özlem
  // ────────────────────────────────────────────────────────────────────

  static const List<NotifSimpleMessage> reEngagementTr = [
    NotifSimpleMessage(title: 'Anneciğim, seni özledim! 😢', body: 'Birkaç gündür gelmedin. İyimisin? Seni burada bekliyordum 💗'),
    NotifSimpleMessage(title: 'Ben büyümeye devam ediyorum! 🌱', body: 'Her gün değişiyorum anneciğim — kaçırmak istemezsin 😊 Gel, bakalım 🌸'),
    NotifSimpleMessage(title: 'Seni çok özledim anneciğim! 💔', body: 'Bir nebze uğrar mısın? Seninle birlikte büyümek istiyorum 🥺'),
    NotifSimpleMessage(title: 'Hâlâ buradayım anneciğim! 🌈', body: 'Gelmeni bekliyorum. Bu anı birlikte yaşayalım 💕'),
    NotifSimpleMessage(title: 'Annemi arıyorum! 📣', body: 'Neredesin anneciğim? Büyüyor ve seni bekliyorum 🌸'),
  ];

  static const List<NotifSimpleMessage> reEngagementEn = [
    NotifSimpleMessage(title: 'I miss you mommy! 😢', body: 'Haven\'t seen you in a few days. Are you okay? I\'ve been waiting 💗'),
    NotifSimpleMessage(title: 'I\'m still growing! 🌱', body: 'I change every day — you don\'t want to miss it 😊 Come see! 🌸'),
    NotifSimpleMessage(title: 'I miss you so much mommy! 💔', body: 'Could you stop by? I want to grow with you 🥺'),
    NotifSimpleMessage(title: 'Still here mommy! 🌈', body: 'Waiting for you. Let\'s experience this moment together 💕'),
  ];

  // ────────────────────────────────────────────────────────────────────
  // Kategori 5 — Günlük Bebek Becerisi Sürprizi
  // ────────────────────────────────────────────────────────────────────

  static const List<NotifSimpleMessage> dailyBabyFactTr = [
    NotifSimpleMessage(title: 'Anneciğim, tahmin et! 🤔', body: 'Bugün ilk kez yutuyor gibiyim! Ne yediysen ben de tattım 😋'),
    NotifSimpleMessage(title: 'Haber var anneciğim! 📢', body: 'Bu hafta beyin dalgalarım ölçülebilir hale geldi! Zeki biri olacağım 🧠✨'),
    NotifSimpleMessage(title: 'Sürpriz anneciğim! 🎁', body: 'Artık tat almaya başladım — sen ne yiyorsun? Ben de hissediyorum 😄'),
    NotifSimpleMessage(title: 'Bugün kıpırdadım! 💃', body: 'İlk hareket denemelerim başladı anneciğim! Az sonra hissedeceksin 🌟'),
    NotifSimpleMessage(title: 'Sesini duyuyorum! 🎵', body: 'Sesin bana ulaşıyor anneciğim. Şarkı söylersen çok mutlu oluyorum 🎶'),
    NotifSimpleMessage(title: 'Yeni bir şey öğrendim! 📚', body: 'Bugün yutuyor ve soluklanıyorum — doğuma hazırlanıyorum! 🌬️'),
    NotifSimpleMessage(title: 'Büyüyor muyum? 📏', body: 'Her gün birkaç milim büyüyorum anneciğim! Yakında hissedeceksin 🌱'),
    NotifSimpleMessage(title: 'İlginç bir bilgi! 🔬', body: 'Parmak izlerim şekillendi anneciğim — dünyada bir tane benim var! ✨'),
    NotifSimpleMessage(title: 'Anneciğim günaydın! ☀️', body: 'Bu sabah beyin hücrelerim çoğaldı. Her gün daha zeki oluyorum 🧠'),
    NotifSimpleMessage(title: 'Küçük bir sır! 🤫', body: 'Kalp atışımı duydun mu? O bip bip sesler benden sana mektup 💌'),
  ];

  static const List<NotifSimpleMessage> dailyBabyFactEn = [
    NotifSimpleMessage(title: 'Guess what mommy! 🤔', body: 'Today I started swallowing! Whatever you eat, I taste it too 😋'),
    NotifSimpleMessage(title: 'News from me! 📢', body: 'My brain waves are measurable now! I\'m going to be so smart 🧠✨'),
    NotifSimpleMessage(title: 'Surprise mommy! 🎁', body: 'I can taste now — what are you eating? I feel it too 😄'),
    NotifSimpleMessage(title: 'I moved today! 💃', body: 'My first movements have started mommy! You will feel it soon 🌟'),
    NotifSimpleMessage(title: 'I can hear you! 🎵', body: 'Your voice reaches me mommy. I love it when you sing 🎶'),
    NotifSimpleMessage(title: 'I learned something new! 📚', body: 'Today I\'m practicing swallowing and breathing — preparing for birth! 🌬️'),
    NotifSimpleMessage(title: 'Am I growing? 📏', body: 'I grow a few millimeters every day mommy! Feel me soon 🌱'),
    NotifSimpleMessage(title: 'A fun fact! 🔬', body: 'My fingerprints are formed — there\'s only one me in the world! ✨'),
  ];

  // ────────────────────────────────────────────────────────────────────
  // Yardımcı Metodlar
  // ────────────────────────────────────────────────────────────────────

  /// Haftaya göre gelişim mesajını döndür (yoksa en yakın hafta mesajı)
  static NotifWeeklyMessage getWeeklyMessage(int week, String langCode) {
    final map = langCode == 'tr' ? weeklyDevelopmentTr : weeklyDevelopmentEn;
    if (map.containsKey(week)) return map[week]!;
    final keys = map.keys.toList()..sort();
    int closest = keys.first;
    for (final k in keys) {
      if (k <= week) closest = k;
    }
    return map[closest]!;
  }

  static NotifSimpleMessage getDailyJournal(int dayIndex, String langCode) {
    final list = langCode == 'tr' ? dailyJournalTr : dailyJournalEn;
    return list[dayIndex % list.length];
  }

  static NotifSimpleMessage getDailyVitamin(int dayIndex, String langCode) {
    final list = langCode == 'tr' ? dailyVitaminTr : dailyVitaminEn;
    return list[dayIndex % list.length];
  }

  static NotifSimpleMessage getReEngagement(int dayIndex, String langCode) {
    final list = langCode == 'tr' ? reEngagementTr : reEngagementEn;
    return list[dayIndex % list.length];
  }

  static NotifSimpleMessage getDailyBabyFact(int dayIndex, String langCode) {
    final list = langCode == 'tr' ? dailyBabyFactTr : dailyBabyFactEn;
    return list[dayIndex % list.length];
  }
}

/// Haftalık gelişim mesajı modeli
class NotifWeeklyMessage {
  final String title;
  final String body;
  const NotifWeeklyMessage({required this.title, required this.body});
}

/// Basit bildirim mesajı modeli
class NotifSimpleMessage {
  final String title;
  final String body;
  const NotifSimpleMessage({required this.title, required this.body});
}
