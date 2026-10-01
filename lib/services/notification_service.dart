import 'io_stubs.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/notification_messages.dart';

/// Aura Pregnancy — Yerel Bildirim Servisi
/// Bebek perspektifinden yazılmış duygusal bildirimler.
/// Tamamen offline çalışır, sunucu gerektirmez.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Bildirim ID Sabitleri ───────────────────────────────────────────────
  static const int _weeklyDevId = 1000;
  static const int _dailyJournalId = 2000;
  static const int _dailyVitaminId = 3000;
  static const int _reEngageId = 4000;
  static const int _dailyFactId = 5000;

  // ─── Android Kanal Sabitleri ─────────────────────────────────────────────
  static const String _chanDev = 'aura_dev_channel';
  static const String _chanJournal = 'aura_journal_channel';
  static const String _chanVitamin = 'aura_vitamin_channel';
  static const String _chanReEngage = 'aura_reengage_channel';
  static const String _chanFact = 'aura_fact_channel';

  // ─── Başlatma ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) return; // Web platformunda bildirim yok

    // Timezone veri tabanını yükle
    tz.initializeTimeZones();
    try {
      final localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone.identifier));
    } catch (e) {
      debugPrint('[NotificationService] Yerel saat dilimi alınamadı: $e');
    }

    // Android başlatma ayarları
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS başlatma ayarları
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    // Android bildirim kanallarını oluştur
    if (!kIsWeb && Platform.isAndroid) {
      await _createAndroidChannels();
    }

    // iOS izin iste
    if (!kIsWeb && Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Android 13+ bildirim izni
    if (!kIsWeb && Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
    debugPrint('[NotificationService] Başlatıldı ✓');
  }

  // ─── Tüm Bildirimleri Yeniden Zamanla ────────────────────────────────────

  /// Profil yüklendikten sonra çağrılır. Mevcut haftaya ve dile göre
  /// tüm tekrarlı bildirimleri yeniden planlar.
  Future<void> rescheduleAll({
    required int currentWeek,
    required String langCode,
  }) async {
    if (!_initialized || kIsWeb) return;

    await cancelAll();

    final now = DateTime.now();
    final dayIndex = now.day + now.month * 31; // basit deterministik indeks

    await _scheduleWeeklyDevelopment(currentWeek, langCode);
    await _scheduleDailyJournal(dayIndex, langCode);
    await _scheduleDailyVitamin(dayIndex, langCode);
    await _scheduleDailyBabyFact(dayIndex, langCode);
    // Not: re-engagement, uygulama arka plana geçince ayrıca zamanlanır

    debugPrint('[NotificationService] Tüm bildirimler zamanlandı ✓');
  }

  // ─── Kategori 1: Haftalık Gelişim (Pazartesi 09:00) ─────────────────────

  Future<void> _scheduleWeeklyDevelopment(int week, String lang) async {
    final msg = NotificationMessages.getWeeklyMessage(week, lang);
    try {
      await _plugin.zonedSchedule(
        _weeklyDevId,
        msg.title,
        msg.body,
        _nextWeekday(DateTime.monday, 9, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chanDev,
            'Bebek Gelişimi',
            channelDescription: 'Haftalık bebek gelişim bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(msg.body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('[NotificationService] Haftalık bildirim hatası: $e');
    }
  }

  // ─── Kategori 2: Günlük Anı Hatırlatıcısı (Her gün 20:00) ───────────────

  Future<void> _scheduleDailyJournal(int dayIndex, String lang) async {
    final msg = NotificationMessages.getDailyJournal(dayIndex, lang);
    try {
      await _plugin.zonedSchedule(
        _dailyJournalId,
        msg.title,
        msg.body,
        _nextDailyTime(20, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chanJournal,
            'Günlük Hatırlatıcı',
            channelDescription: 'Günlük anı yazma hatırlatıcıları',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            styleInformation: BigTextStyleInformation(msg.body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('[NotificationService] Günlük anı bildirim hatası: $e');
    }
  }

  // ─── Kategori 3: Vitamin / Su Hatırlatıcısı (Her gün 08:30) ─────────────

  Future<void> _scheduleDailyVitamin(int dayIndex, String lang) async {
    final msg = NotificationMessages.getDailyVitamin(dayIndex, lang);
    try {
      await _plugin.zonedSchedule(
        _dailyVitaminId,
        msg.title,
        msg.body,
        _nextDailyTime(8, 30),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chanVitamin,
            'Vitamin & Su',
            channelDescription: 'Günlük vitamin ve su hatırlatıcıları',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            styleInformation: BigTextStyleInformation(msg.body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('[NotificationService] Vitamin bildirim hatası: $e');
    }
  }

  // ─── Kategori 4: Re-Engagement (3 gün sonra, tek seferlik) ──────────────

  Future<void> scheduleReEngagementFromNow(int dayIndex, String lang) async {
    if (!_initialized || kIsWeb) return;

    // Önce mevcut re-engagement bildirimini iptal et
    await _plugin.cancel(_reEngageId);

    final msg = NotificationMessages.getReEngagement(dayIndex, lang);
    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      const Duration(days: 3),
    );

    try {
      await _plugin.zonedSchedule(
        _reEngageId,
        msg.title,
        msg.body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chanReEngage,
            'Özlem Bildirimi',
            channelDescription: 'Uygulamaya geri dönüş hatırlatıcıları',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(msg.body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
          '[NotificationService] Re-engagement zamanlandı: $scheduledDate');
    } catch (e) {
      debugPrint('[NotificationService] Re-engagement bildirim hatası: $e');
    }
  }

  /// Kullanıcı uygulamayı açtığında re-engagement bildirimini iptal et
  Future<void> cancelReEngagement() async {
    if (!_initialized || kIsWeb) return;
    await _plugin.cancel(_reEngageId);
    debugPrint('[NotificationService] Re-engagement iptal edildi ✓');
  }

  // ─── Kategori 5: Günlük Bebek Becerisi (Her gün 12:00) ──────────────────

  Future<void> _scheduleDailyBabyFact(int dayIndex, String lang) async {
    final msg = NotificationMessages.getDailyBabyFact(dayIndex, lang);
    try {
      await _plugin.zonedSchedule(
        _dailyFactId,
        msg.title,
        msg.body,
        _nextDailyTime(12, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chanFact,
            'Bebek Sürprizi',
            channelDescription: 'Günlük bebek gelişim sürprizleri',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            styleInformation: BigTextStyleInformation(msg.body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint(
          '[NotificationService] Günlük bebek bilgisi bildirim hatası: $e');
    }
  }

  // ─── İptal İşlemleri ─────────────────────────────────────────────────────

  Future<void> cancelAll() async {
    if (!_initialized || kIsWeb) return;
    await _plugin.cancelAll();
    debugPrint('[NotificationService] Tüm bildirimler iptal edildi');
  }

  // ─── Yardımcı Metodlar ───────────────────────────────────────────────────

  /// Belirtilen saatte bir sonraki zamanı hesapla (günlük tekrar için)
  tz.TZDateTime _nextDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Belirtilen haftanın gününde bir sonraki zamanı hesapla
  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    var now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Android bildirim kanallarını oluştur
  Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin
        .createNotificationChannel(const AndroidNotificationChannel(
      _chanDev,
      'Bebek Gelişimi',
      description: 'Haftalık bebek gelişim bildirimleri',
      importance: Importance.high,
    ));
    await androidPlugin
        .createNotificationChannel(const AndroidNotificationChannel(
      _chanJournal,
      'Günlük Hatırlatıcı',
      description: 'Günlük anı yazma hatırlatıcıları',
      importance: Importance.defaultImportance,
    ));
    await androidPlugin
        .createNotificationChannel(const AndroidNotificationChannel(
      _chanVitamin,
      'Vitamin & Su',
      description: 'Günlük vitamin ve su hatırlatıcıları',
      importance: Importance.defaultImportance,
    ));
    await androidPlugin
        .createNotificationChannel(const AndroidNotificationChannel(
      _chanReEngage,
      'Özlem Bildirimi',
      description: 'Uygulamaya geri dönüş hatırlatıcıları',
      importance: Importance.high,
    ));
    await androidPlugin
        .createNotificationChannel(const AndroidNotificationChannel(
      _chanFact,
      'Bebek Sürprizi',
      description: 'Günlük bebek gelişim sürprizleri',
      importance: Importance.defaultImportance,
    ));
    debugPrint('[NotificationService] Android kanalları oluşturuldu ✓');
  }

  // ─── Bildirim Tıklama Handler ─────────────────────────────────────────────

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] Bildirime tıklandı: ${response.id}');
    // NavigatorKey üzerinden yönlendirme yapılabilir (ileride genişletilebilir)
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint(
        '[NotificationService] Arka plan bildirime tıklandı: ${response.id}');
  }
}
