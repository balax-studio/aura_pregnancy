import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

/// Local reminders for the daily pregnancy note and baby messages.
class PregnancyNotificationService {
  PregnancyNotificationService._();

  static final PregnancyNotificationService instance =
      PregnancyNotificationService._();

  static const int _firstDailyNotificationId = 9200;
  static const int _afterExitNotificationId = 9300;
  static const int _daysScheduledAhead = 30;
  static const int _morningHour = 9;
  static const int _eveningHour = 20;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void>? _initialization;

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get isSupportedPlatform => _isSupportedPlatform;

  static const InitializationSettings _initializationSettings =
      InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'aura_pregnancy_messages',
      'Aura Pregnancy',
      channelDescription: 'Günlük mesajlar ve bebek notları',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(
      threadIdentifier: 'aura_pregnancy_messages',
    ),
  );

  Future<void> initialize() async {
    if (!_isSupportedPlatform) return;

    if (!_initialized) {
      _initialization ??= _initializePlugin();
      try {
        await _initialization;
      } catch (_) {
        _initialization = null;
        rethrow;
      }
    } else {
      await _setLocalTimezone();
    }
  }

  Future<void> _initializePlugin() async {
    timezone_data.initializeTimeZones();
    await _setLocalTimezone();
    await _plugin.initialize(_initializationSettings);
    _initialized = true;
  }

  Future<void> _setLocalTimezone() async {
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));
  }

  Future<bool> hasNotificationPermission() async {
    if (!_isSupportedPlatform) return false;
    return (await Permission.notification.status).isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    if (!_isSupportedPlatform) return false;
    await initialize();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  Future<void> scheduleDailyMessages({required String languageCode}) async {
    if (!_isSupportedPlatform || !_initialized) return;

    await clearDailyMessages();

    for (var dayOffset = 0; dayOffset < _daysScheduledAhead; dayOffset++) {
      final messageIndex = DateTime.now().day + dayOffset;
      final morning = _nextLocalTime(dayOffset, _morningHour);
      if (morning.isAfter(timezone.TZDateTime.now(timezone.local))) {
        await _plugin.zonedSchedule(
          _morningNotificationId(dayOffset),
          _dailyTitle(languageCode),
          _dailyMessage(languageCode, messageIndex),
          morning,
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }

      final evening = _nextLocalTime(dayOffset, _eveningHour);
      if (evening.isAfter(timezone.TZDateTime.now(timezone.local))) {
        await _plugin.zonedSchedule(
          _eveningNotificationId(dayOffset),
          _babyTitle(languageCode),
          _babyMessage(languageCode, messageIndex),
          evening,
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> clearDailyMessages() async {
    if (!_isSupportedPlatform || !_initialized) return;
    for (var dayOffset = 0; dayOffset < _daysScheduledAhead; dayOffset++) {
      await _plugin.cancel(_morningNotificationId(dayOffset));
      await _plugin.cancel(_eveningNotificationId(dayOffset));
    }
  }

  Future<void> scheduleAfterExitMessage({required String languageCode}) async {
    if (!_isSupportedPlatform || !_initialized) return;

    final scheduledTime =
        timezone.TZDateTime.now(timezone.local).add(const Duration(hours: 1));
    final index = DateTime.now().day + DateTime.now().hour;
    await _plugin.cancel(_afterExitNotificationId);
    await _plugin.zonedSchedule(
      _afterExitNotificationId,
      _babyTitle(languageCode),
      _afterExitMessage(languageCode, index),
      scheduledTime,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelAfterExitMessage() async {
    if (!_isSupportedPlatform || !_initialized) return;
    await _plugin.cancel(_afterExitNotificationId);
  }

  int _morningNotificationId(int dayOffset) =>
      _firstDailyNotificationId + dayOffset * 2;

  int _eveningNotificationId(int dayOffset) =>
      _firstDailyNotificationId + dayOffset * 2 + 1;

  timezone.TZDateTime _nextLocalTime(int dayOffset, int hour) {
    final now = timezone.TZDateTime.now(timezone.local);
    return timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day + dayOffset,
      hour,
    );
  }

  String _dailyTitle(String languageCode) =>
      languageCode == 'tr' ? 'Günün mesajı 🌷' : 'Your daily note 🌷';

  String _babyTitle(String languageCode) => languageCode == 'tr'
      ? 'Bebeğinden minik bir not 💛'
      : 'A note from your baby 💛';

  String _dailyMessage(String languageCode, int index) => _messageAt(
      languageCode == 'tr' ? _dailyMessagesTr : _dailyMessagesEn, index);

  String _babyMessage(String languageCode, int index) => _messageAt(
      languageCode == 'tr' ? _babyMessagesTr : _babyMessagesEn, index);

  String _afterExitMessage(String languageCode, int index) => _messageAt(
        languageCode == 'tr' ? _afterExitMessagesTr : _afterExitMessagesEn,
        index,
      );

  String _messageAt(List<String> messages, int index) =>
      messages[index % messages.length];

  static const List<String> _dailyMessagesTr = [
    'Bugün kendine de şefkat göstermeyi unutma. 🌷',
    'Küçük bir mola, gününe güzel bir nefes olsun. ☁️',
    'Her gün her şeyi yetiştirmek zorunda değilsin. 💛',
    'Bugün de elinden gelenin en iyisi yeterli. 🌼',
    'Kendine ayırdığın birkaç dakika da çok kıymetli. ✨',
    'Yavaşlamak da bu yolculuğun güzel bir parçası. 🌿',
    'Bugün kendine güzel bir söz söyle. Sen çok değerlisin. 💕',
  ];

  static const List<String> _dailyMessagesEn = [
    'Remember to show yourself a little kindness today. 🌷',
    'Let a small pause bring a gentle breath to your day. ☁️',
    'You do not have to do everything today. 💛',
    'Doing your best today is enough. 🌼',
    'A few minutes for yourself matter, too. ✨',
    'Slowing down is a lovely part of this journey. 🌿',
    'Say something kind to yourself today. You matter. 💕',
  ];

  static const List<String> _babyMessagesTr = [
    'Anneciğim, sana kocaman bir sevgi notu bıraktım. 💌',
    'Minik bir selam gönderdim; bugün de yan yanayız. 💛',
    'Bana ayırdığın sevgi dolu anlar çok güzel. 🌸',
    'Birlikte geçirdiğimiz bu yolculuk ne tatlı, değil mi? 💕',
    'Bugün de kalbinde bana yer açtığın için teşekkürler. 🧸',
    'Sana minik bir öpücük ve kocaman bir sarılma gönderdim. 😘',
    'Anneciğim, bu güzel yolculukta birbirimize eşlik ediyoruz. 🌷',
  ];

  static const List<String> _babyMessagesEn = [
    'Mommy, I left you a little note full of love. 💌',
    'Sending a tiny hello; we are together today, too. 💛',
    'The loving moments you share with me are lovely. 🌸',
    'What a sweet journey we are sharing, right? 💕',
    'Thank you for keeping a little space for me in your heart. 🧸',
    'Sending you a tiny kiss and a big cuddle. 😘',
    'Mommy, we are keeping each other company on this journey. 🌷',
  ];

  static const List<String> _afterExitMessagesTr = [
    'Anneciğim, günün arasında sana minik bir selam bırakayım dedim. 💛',
    'Biraz dinlenme vakti mi? Sana sevgilerimi gönderiyorum. 🌸',
    'Telefonu bıraktın ama sana sevgim hep yanında. 💌',
    'Minik bir mola ver; sana kocaman sevgiler gönderiyorum. 🌷',
  ];

  static const List<String> _afterExitMessagesEn = [
    'Mommy, I wanted to leave you a tiny hello during your day. 💛',
    'Time for a little rest? Sending you all my love. 🌸',
    'You put your phone down, but my love is still with you. 💌',
    'Take a little pause; sending you a big bundle of love. 🌷',
  ];
}
