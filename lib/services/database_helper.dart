import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' if (dart.library.html) 'database_stubs.dart';
import '../models/profile_model.dart';
import '../models/diary_model.dart';
import '../models/daily_log_model.dart';
import '../models/notification_model.dart';
import '../models/medication_model.dart';
import '../models/emergency_card_model.dart';
import '../models/baby_name_model.dart';
import '../models/hospital_bag_item.dart';
import '../models/doctor_question_model.dart';
import '../models/time_capsule_model.dart';
import '../models/birth_plan_model.dart';
import '../core/constants/doctor_questions_data.dart';

/// Aura Pregnancy - SQLite & Web Uyumlu Yerel Veritabanı Yöneticisi (DatabaseHelper)
class DatabaseHelper {
  static const String _databaseName = 'aura_pregnancy.db';
  static const int _databaseVersion = 6;

  // Singleton Örneği
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  /// Canlı Reaktif Veri Değişim Bildiricisi (Tüm ekranları anında günceller)
  static final ValueNotifier<int> appDataRevision = ValueNotifier<int>(0);
  static void notifyDataChanged() {
    appDataRevision.value++;
  }

  static Database? _database;
  bool _useFallback = false;

  // Web veya Fallback ortamı için In-Memory Depolama
  ProfileModel? _webProfile;
  final List<DiaryModel> _webDiaries = [];
  final Map<String, DailyLogModel> _webDailyLogs = {};
  final List<NotificationModel> _webNotifications = [];
  final List<MedicationModel> _webMedications = [];
  EmergencyCardModel? _webEmergencyCard;
  bool _webMedicationsSeeded = false;
  int _webResetCount = 0;
  final List<BabyNameModel> _webFavoriteNames = [];
  final Map<String, String> _webSettings = {};
  final List<HospitalBagItem> _webHospitalBag = [];
  bool _webHospitalBagSeeded = false;
  final List<DoctorQuestion> _webDoctorQuestions = [];
  bool _webDoctorQuestionsSeeded = false;
  final List<TimeCapsuleLetter> _webTimeCapsule = [];
  BirthPlanModel _webBirthPlan = const BirthPlanModel();
  final Set<String> _webSafetyFavorites = {};

  /// Veritabanı örneğini döndürür (Lazy initialization)
  Future<Database?> get database async {
    if (kIsWeb || _useFallback) {
      return null;
    }
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint('Database initialization warning: $e -> Fallback to in-memory store.');
      _useFallback = true;
      return null;
    }
  }

  /// Veritabanı başlatma
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Tabloları Oluşturma
  Future<void> _onCreate(Database db, int version) async {
    // 1. profile tablosu (Anne, Bebek İsmi ve Cinsiyet Alanları Dahil)
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        due_date TEXT NOT NULL,
        lmp_date TEXT,
        pre_pregnancy_weight REAL NOT NULL,
        height REAL NOT NULL,
        vki REAL NOT NULL,
        current_week INTEGER NOT NULL,
        mom_name TEXT,
        partner_name TEXT,
        baby_name TEXT,
        baby_gender TEXT DEFAULT 'surprise'
      )
    ''');

    // 2. diary (Anı Günlüğü) tablosu
    await db.execute('''
      CREATE TABLE diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pregnancy_week INTEGER NOT NULL,
        date TEXT NOT NULL,
        note_text TEXT,
        photo_path TEXT,
        audio_path TEXT,
        mood_rating INTEGER DEFAULT 5,
        is_romantic_highlight INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 3. daily_log (Günlük Su, Kafein, Adım, Yürüyüş, Kilo, Semptom) tablosu
    await db.execute('''
      CREATE TABLE daily_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        water_intake_ml INTEGER NOT NULL DEFAULT 0,
        caffeine_mg INTEGER NOT NULL DEFAULT 0,
        step_count INTEGER NOT NULL DEFAULT 0,
        walking_minutes INTEGER NOT NULL DEFAULT 0,
        weight_entry REAL,
        symptom_notes TEXT
      )
    ''');

    // 4. notifications tablosu
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week INTEGER NOT NULL,
        trigger_time TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL
      )
    ''');

    // 5. medications (İlaç ve Vitamin Takip) tablosu
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT,
        time TEXT,
        last_taken_date TEXT,
        category TEXT
      )
    ''');

    // 6. emergency_card (Kişiselleştirilebilir Acil Tıbbi Kart) tablosu
    await db.execute('''
      CREATE TABLE emergency_card (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        patient_name TEXT,
        blood_type TEXT,
        lmp_date TEXT,
        due_date TEXT,
        current_week INTEGER,
        allergies TEXT,
        chronic_diseases TEXT,
        medications TEXT,
        emergency_contact_name TEXT,
        emergency_contact_phone TEXT,
        doctor_name TEXT,
        doctor_phone TEXT,
        hospital_name TEXT,
        recent_symptoms TEXT
      )
    ''');

    // 7. app_settings (Sistem Ayarları ve Seeding Durumu) tablosu
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // 8. favorite_names (Favori Bebek İsimleri) tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_names (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        gender TEXT NOT NULL,
        origin TEXT NOT NULL,
        meaning TEXT NOT NULL,
        characteristics TEXT NOT NULL,
        cultural_note TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 9. hospital_bag_items tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hospital_bag_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        is_packed INTEGER DEFAULT 0,
        is_custom INTEGER DEFAULT 0,
        quantity INTEGER DEFAULT 1
      )
    ''');

    // 10. doctor_questions tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS doctor_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pregnancy_week INTEGER NOT NULL,
        trimester INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer_note TEXT,
        is_answered INTEGER DEFAULT 0,
        is_predefined INTEGER DEFAULT 0,
        created_date TEXT NOT NULL
      )
    ''');

    // 11. future_time_capsule tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS future_time_capsule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        unlock_milestone TEXT NOT NULL,
        title TEXT NOT NULL,
        letter_text TEXT NOT NULL,
        audio_path TEXT,
        photo_path TEXT,
        is_sealed INTEGER DEFAULT 1,
        created_date TEXT NOT NULL,
        target_unlock_date TEXT NOT NULL
      )
    ''');

    // 12. birth_plan tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS birth_plan (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        dim_lights INTEGER DEFAULT 1,
        ambient_music INTEGER DEFAULT 1,
        aromatherapy INTEGER DEFAULT 0,
        quiet_environment INTEGER DEFAULT 1,
        epidural_preferred INTEGER DEFAULT 0,
        natural_pain_relief INTEGER DEFAULT 1,
        birthing_ball INTEGER DEFAULT 1,
        warm_water_shower INTEGER DEFAULT 1,
        delayed_cord_clamping INTEGER DEFAULT 1,
        partner_cuts_cord INTEGER DEFAULT 1,
        immediate_skin_to_skin INTEGER DEFAULT 1,
        delay_newborn_bath_24h INTEGER DEFAULT 1,
        discuss_before_intervention INTEGER DEFAULT 1,
        spontaneous_pushing INTEGER DEFAULT 1,
        special_wishes TEXT,
        pediatrician_name TEXT,
        emergency_contact TEXT
      )
    ''');

    // 13. safety_cravings tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS safety_cravings (
        item_id TEXT PRIMARY KEY
      )
    ''');

    // İndeksler (Hızlı sorgulama için)
    await db.execute('CREATE INDEX idx_diary_week ON diary(pregnancy_week)');
    await db.execute('CREATE INDEX idx_diary_date ON diary(date)');
    await db.execute('CREATE INDEX idx_daily_log_date ON daily_log(date)');
    await db.execute('CREATE INDEX idx_notif_week ON notifications(week)');
  }

  /// Veritabanı Yükseltme / Migrasyon
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE daily_log ADD COLUMN step_count INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE daily_log ADD COLUMN walking_minutes INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE profile ADD COLUMN mom_name TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE profile ADD COLUMN partner_name TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE profile ADD COLUMN baby_name TEXT');
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE profile ADD COLUMN baby_gender TEXT DEFAULT 'surprise'");
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS medications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dosage TEXT,
            time TEXT,
            last_taken_date TEXT,
            category TEXT
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 5) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS emergency_card (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            patient_name TEXT,
            blood_type TEXT,
            lmp_date TEXT,
            due_date TEXT,
            current_week INTEGER,
            allergies TEXT,
            chronic_diseases TEXT,
            medications TEXT,
            emergency_contact_name TEXT,
            emergency_contact_phone TEXT,
            doctor_name TEXT,
            doctor_phone TEXT,
            hospital_name TEXT,
            recent_symptoms TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS app_settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 6) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS hospital_bag_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            title TEXT NOT NULL,
            is_packed INTEGER DEFAULT 0,
            is_custom INTEGER DEFAULT 0,
            quantity INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS doctor_questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pregnancy_week INTEGER NOT NULL,
            trimester INTEGER NOT NULL,
            question TEXT NOT NULL,
            answer_note TEXT,
            is_answered INTEGER DEFAULT 0,
            is_predefined INTEGER DEFAULT 0,
            created_date TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS future_time_capsule (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            unlock_milestone TEXT NOT NULL,
            title TEXT NOT NULL,
            letter_text TEXT NOT NULL,
            audio_path TEXT,
            photo_path TEXT,
            is_sealed INTEGER DEFAULT 1,
            created_date TEXT NOT NULL,
            target_unlock_date TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS birth_plan (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            dim_lights INTEGER DEFAULT 1,
            ambient_music INTEGER DEFAULT 1,
            aromatherapy INTEGER DEFAULT 0,
            quiet_environment INTEGER DEFAULT 1,
            epidural_preferred INTEGER DEFAULT 0,
            natural_pain_relief INTEGER DEFAULT 1,
            birthing_ball INTEGER DEFAULT 1,
            warm_water_shower INTEGER DEFAULT 1,
            delayed_cord_clamping INTEGER DEFAULT 1,
            partner_cuts_cord INTEGER DEFAULT 1,
            immediate_skin_to_skin INTEGER DEFAULT 1,
            delay_newborn_bath_24h INTEGER DEFAULT 1,
            discuss_before_intervention INTEGER DEFAULT 1,
            spontaneous_pushing INTEGER DEFAULT 1,
            special_wishes TEXT,
            pediatrician_name TEXT,
            emergency_contact TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS safety_cravings (
            item_id TEXT PRIMARY KEY
          )
        ''');
      } catch (_) {}
    }
  }

  // ==========================================
  // 1. PROFİL CRUD İŞLEMLERİ
  // ==========================================

  Future<int> saveProfile(ProfileModel profile) async {
    final db = await database;
    if (db == null) {
      final savedId = profile.id ?? 1;
      _webProfile = profile.copyWith(id: savedId);
      _webSettings['is_onboarding_completed'] = 'true';
      notifyDataChanged();
      return savedId;
    }
    try {
      final maps = await db.query('profile', limit: 1);
      int savedId;
      if (maps.isNotEmpty) {
        final existingId = maps.first['id'] as int;
        final map = profile.toMap();
        map.remove('id');
        await db.update(
          'profile',
          map,
          where: 'id = ?',
          whereArgs: [existingId],
        );
        savedId = existingId;
      } else {
        final map = profile.toMap();
        map.remove('id');
        savedId = await db.insert('profile', map);
      }
      _webProfile = profile.copyWith(id: savedId);
      await setSetting('is_onboarding_completed', 'true');
      notifyDataChanged();
      return savedId;
    } catch (e) {
      debugPrint('saveProfile db error, using fallback: $e');
      final fallbackId = profile.id ?? 1;
      _webProfile = profile.copyWith(id: fallbackId);
      _webSettings['is_onboarding_completed'] = 'true';
      notifyDataChanged();
      return fallbackId;
    }
  }

  Future<ProfileModel?> getProfile() async {
    final db = await database;
    if (db == null) {
      return _webProfile;
    }
    try {
      final maps = await db.query('profile', limit: 1);
      if (maps.isNotEmpty) {
        final prof = ProfileModel.fromMap(maps.first);
        _webProfile = prof;
        return prof;
      }
      return null;
    } catch (e) {
      debugPrint('getProfile db error, using fallback: $e');
      return _webProfile;
    }
  }

  Future<ProfileModel> ensureDefaultProfile() async {
    final existing = await getProfile();
    if (existing != null) return existing;
    final now = DateTime.now();
    final defaultLmp = now.subtract(const Duration(days: 84));
    final defaultDue = defaultLmp.add(const Duration(days: 280));
    final defaultProfile = ProfileModel(
      dueDate: defaultDue.toIso8601String(),
      lmpDate: defaultLmp.toIso8601String(),
      prePregnancyWeight: 60.0,
      height: 165.0,
      vki: 22.0,
      currentWeek: 12,
    );
    final id = await saveProfile(defaultProfile);
    return defaultProfile.copyWith(id: id);
  }

  Future<int> updateCurrentWeek(int week) async {
    if (_webProfile != null) {
      _webProfile = _webProfile!.copyWith(currentWeek: week);
    }
    final db = await database;
    notifyDataChanged();
    if (db == null) {
      return 1;
    }
    try {
      final res = await db.rawUpdate('UPDATE profile SET current_week = ?', [week]);
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('updateCurrentWeek error: $e');
      notifyDataChanged();
      return 1;
    }
  }

  // ==========================================
  // 2. DIARY (GÜNLÜK & ANI) CRUD İŞLEMLERİ
  // ==========================================

  Future<int> insertDiary(DiaryModel diary) async {
    final newId = _webDiaries.length + 1;
    final modelWithId = diary.copyWith(id: diary.id ?? newId);
    _webDiaries.add(modelWithId);
    notifyDataChanged();

    final db = await database;
    if (db == null) {
      return newId;
    }
    try {
      final res = await db.insert('diary', diary.toMap());
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('insertDiary error: $e');
      notifyDataChanged();
      return newId;
    }
  }

  Future<List<DiaryModel>> getAllDiaries() async {
    final db = await database;
    if (db == null) {
      return List.from(_webDiaries.reversed);
    }
    try {
      final result = await db.query('diary', orderBy: 'date DESC, id DESC');
      if (result.isEmpty && _webDiaries.isNotEmpty) {
        return List.from(_webDiaries.reversed);
      }
      return result.map((m) => DiaryModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('getAllDiaries error: $e');
      return List.from(_webDiaries.reversed);
    }
  }

  Future<List<DiaryModel>> getDiariesByWeek(int week) async {
    final db = await database;
    if (db == null) {
      return _webDiaries.where((d) => d.pregnancyWeek == week).toList();
    }
    try {
      final result = await db.query(
        'diary',
        where: 'pregnancy_week = ?',
        whereArgs: [week],
        orderBy: 'date DESC',
      );
      if (result.isEmpty) {
        return _webDiaries.where((d) => d.pregnancyWeek == week).toList();
      }
      return result.map((m) => DiaryModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('getDiariesByWeek error: $e');
      return _webDiaries.where((d) => d.pregnancyWeek == week).toList();
    }
  }

  Future<List<DiaryModel>> getRomanticHighlights() async {
    final db = await database;
    if (db == null) {
      return _webDiaries.where((d) => d.isRomanticHighlight).toList();
    }
    try {
      final result = await db.query(
        'diary',
        where: 'is_romantic_highlight = 1',
        orderBy: 'pregnancy_week ASC, date ASC',
      );
      if (result.isEmpty) {
        return _webDiaries.where((d) => d.isRomanticHighlight).toList();
      }
      return result.map((m) => DiaryModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('getRomanticHighlights error: $e');
      return _webDiaries.where((d) => d.isRomanticHighlight).toList();
    }
  }

  Future<int> updateDiary(DiaryModel diary) async {
    final idx = _webDiaries.indexWhere((d) => d.id == diary.id);
    if (idx != -1) {
      _webDiaries[idx] = diary;
    }
    notifyDataChanged();
    final db = await database;
    if (db == null) {
      return idx != -1 ? 1 : 0;
    }
    try {
      final res = await db.update(
        'diary',
        diary.toMap(),
        where: 'id = ?',
        whereArgs: [diary.id],
      );
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('updateDiary error: $e');
      notifyDataChanged();
      return 1;
    }
  }

  Future<int> deleteDiary(int id) async {
    _webDiaries.removeWhere((d) => d.id == id);
    notifyDataChanged();
    final db = await database;
    if (db == null) {
      return 1;
    }
    try {
      final res = await db.delete('diary', where: 'id = ?', whereArgs: [id]);
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('deleteDiary error: $e');
      notifyDataChanged();
      return 1;
    }
  }

  // ==========================================
  // 3. DAILY LOG (GÜNLÜK TAKİP) CRUD İŞLEMLERİ
  // ==========================================

  Future<DailyLogModel> getOrCreateDailyLog(String date) async {
    if (!_webDailyLogs.containsKey(date)) {
      _webDailyLogs[date] = DailyLogModel(date: date, id: _webDailyLogs.length + 1);
    }
    final db = await database;
    if (db == null) {
      return _webDailyLogs[date]!;
    }
    try {
      final result = await db.query(
        'daily_log',
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final log = DailyLogModel.fromMap(result.first);
        _webDailyLogs[date] = log;
        return log;
      } else {
        final newLog = DailyLogModel(date: date);
        final id = await db.insert('daily_log', newLog.toMap());
        final savedLog = newLog.copyWith(id: id);
        _webDailyLogs[date] = savedLog;
        return savedLog;
      }
    } catch (e) {
      debugPrint('getOrCreateDailyLog error: $e');
      return _webDailyLogs[date]!;
    }
  }

  Future<int> updateDailyLog(DailyLogModel log) async {
    _webDailyLogs[log.date] = log;
    notifyDataChanged();
    final db = await database;
    if (db == null) {
      return 1;
    }
    try {
      final res = await db.insert(
        'daily_log',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('updateDailyLog error: $e');
      notifyDataChanged();
      return 1;
    }
  }

  Future<List<DailyLogModel>> getAllDailyLogs() async {
    final db = await database;
    if (db == null) {
      final list = _webDailyLogs.values.toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
    try {
      final result = await db.query('daily_log', orderBy: 'date DESC');
      if (result.isEmpty && _webDailyLogs.isNotEmpty) {
        final list = _webDailyLogs.values.toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      }
      return result.map((m) => DailyLogModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('getAllDailyLogs error: $e');
      final list = _webDailyLogs.values.toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
  }

  Future<List<DailyLogModel>> getRecentLogs(int limit) async {
    final db = await database;
    if (db == null) {
      return _webDailyLogs.values.take(limit).toList();
    }
    try {
      final result = await db.query('daily_log', orderBy: 'date DESC', limit: limit);
      if (result.isEmpty) {
        return _webDailyLogs.values.take(limit).toList();
      }
      return result.map((m) => DailyLogModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('getRecentLogs error: $e');
      return _webDailyLogs.values.take(limit).toList();
    }
  }

  // ==========================================
  // 4. NOTIFICATIONS CRUD İŞLEMLERİ
  // ==========================================

  Future<int> insertNotification(NotificationModel notification) async {
    _webNotifications.add(notification.copyWith(id: _webNotifications.length + 1));
    final db = await database;
    if (db == null) {
      return 1;
    }
    try {
      return await db.insert('notifications', notification.toMap());
    } catch (e) {
      debugPrint('insertNotification error: $e');
      return 1;
    }
  }

  Future<List<NotificationModel>> getNotificationsForWeek(int week) async {
    final db = await database;
    if (db == null) {
      return _webNotifications.where((n) => n.week == week).toList();
    }
    try {
      final result = await db.query(
        'notifications',
        where: 'week = ?',
        whereArgs: [week],
        orderBy: 'trigger_time ASC',
      );
      if (result.isEmpty) {
        return _webNotifications.where((n) => n.week == week).toList();
      }
      return result.map((m) => NotificationModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('getNotificationsForWeek error: $e');
      return _webNotifications.where((n) => n.week == week).toList();
    }
  }

  Future<int> markNotificationAsRead(int id) async {
    final idx = _webNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _webNotifications[idx] = _webNotifications[idx].copyWith(isRead: true);
    }
    final db = await database;
    if (db == null) {
      return 1;
    }
    try {
      return await db.update(
        'notifications',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('markNotificationAsRead error: $e');
      return 1;
    }
  }

  // ==========================================
  // 5. MEDICATIONS (İLAÇ & VİTAMİN TAKİBİ) CRUD İŞLEMLERİ
  // ==========================================

  Future<List<MedicationModel>> getMedications() async {
    final db = await database;
    if (db == null) {
      if (!_webMedicationsSeeded) {
        _webMedicationsSeeded = true;
        await ensureDefaultMedications();
      }
      return List.from(_webMedications);
    }
    try {
      // Sadece uygulama ilk kurulduğunda 1 kez default ilaçları tohumla
      final seededRows = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['medications_seeded'],
      );
      if (seededRows.isEmpty) {
        final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM medications')) ?? 0;
        if (count == 0) {
          await ensureDefaultMedications();
        }
        await db.insert(
          'app_settings',
          {'key': 'medications_seeded', 'value': 'true'},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      final result = await db.query('medications', orderBy: 'id ASC');
      return result.map((m) => MedicationModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('getMedications error: $e');
      return List.from(_webMedications);
    }
  }

  Future<int> insertMedication(MedicationModel medication) async {
    final newId = _webMedications.length + 1;
    final modelWithId = medication.copyWith(id: medication.id ?? newId);
    _webMedications.add(modelWithId);
    notifyDataChanged();

    final db = await database;
    if (db == null) return newId;

    try {
      final id = await db.insert('medications', medication.toMap());
      notifyDataChanged();
      return id;
    } catch (e) {
      debugPrint('insertMedication error: $e');
      return newId;
    }
  }

  Future<int> toggleMedicationTaken(int id, String todayIso, bool isTaken) async {
    final lastTaken = isTaken ? todayIso : null;

    final idx = _webMedications.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _webMedications[idx] = _webMedications[idx].copyWith(lastTakenDate: lastTaken);
    }
    notifyDataChanged();

    final db = await database;
    if (db == null) return 1;

    try {
      final res = await db.update(
        'medications',
        {'last_taken_date': lastTaken},
        where: 'id = ?',
        whereArgs: [id],
      );
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('toggleMedicationTaken error: $e');
      return 1;
    }
  }

  Future<int> deleteMedication(int id) async {
    _webMedications.removeWhere((m) => m.id == id);
    notifyDataChanged();

    final db = await database;
    if (db == null) return 1;

    try {
      final res = await db.delete('medications', where: 'id = ?', whereArgs: [id]);
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('deleteMedication error: $e');
      return 1;
    }
  }

  Future<void> ensureDefaultMedications() async {
    final defaults = [
      MedicationModel(
        name: 'Folik Asit',
        dosage: '400 mcg (1 Tablet)',
        time: 'Sabah Tok',
        category: 'Vitamin',
      ),
      MedicationModel(
        name: 'Demir Takviyesi (Ferrum)',
        dosage: '1 Kapsül',
        time: 'Öğle Aç',
        category: 'Mineral',
      ),
      MedicationModel(
        name: 'D3 Vitamini & Omega-3',
        dosage: '1000 IU',
        time: 'Akşam',
        category: 'Vitamin',
      ),
    ];

    final db = await database;
    if (db == null) {
      if (_webMedications.isEmpty) {
        for (int i = 0; i < defaults.length; i++) {
          _webMedications.add(defaults[i].copyWith(id: i + 1));
        }
      }
      return;
    }

    try {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM medications')) ?? 0;
      if (count == 0) {
        for (final m in defaults) {
          await db.insert('medications', m.toMap());
        }
      }
    } catch (e) {
      debugPrint('ensureDefaultMedications error: $e');
    }
  }

  // ==========================================
  // 6. EMERGENCY CARD (ACİL TIBBİ KART) CRUD İŞLEMLERİ
  // ==========================================

  Future<EmergencyCardModel?> getEmergencyCard() async {
    final db = await database;
    if (db == null) {
      return _webEmergencyCard;
    }
    try {
      final result = await db.query('emergency_card', where: 'id = 1', limit: 1);
      if (result.isNotEmpty) {
        return EmergencyCardModel.fromMap(result.first);
      }
      return _webEmergencyCard;
    } catch (e) {
      debugPrint('getEmergencyCard error: $e');
      return _webEmergencyCard;
    }
  }

  Future<int> saveEmergencyCard(EmergencyCardModel card) async {
    _webEmergencyCard = card;
    notifyDataChanged();

    final db = await database;
    if (db == null) return 1;

    try {
      final map = card.toMap();
      map['id'] = 1;
      final res = await db.insert(
        'emergency_card',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      notifyDataChanged();
      return res;
    } catch (e) {
      debugPrint('saveEmergencyCard error: $e');
      return 1;
    }
  }

  Future<void> _ensureAppSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    if (db == null) {
      return _webSettings[key];
    }
    try {
      await _ensureAppSettingsTable(db);
      final res = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (res.isNotEmpty) {
        final val = res.first['value']?.toString();
        if (val != null) _webSettings[key] = val;
        return val;
      }
      return _webSettings[key];
    } catch (e) {
      debugPrint('getSetting error: $e');
      return _webSettings[key];
    }
  }

  Future<void> setSetting(String key, String value) async {
    _webSettings[key] = value;
    final db = await database;
    if (db != null) {
      try {
        await _ensureAppSettingsTable(db);
        await db.insert(
          'app_settings',
          {'key': key, 'value': value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('setSetting error: $e');
      }
    }
  }

  Future<bool> isOnboardingCompleted() async {
    final val = await getSetting('is_onboarding_completed');
    return val == 'true';
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await setSetting('is_onboarding_completed', completed ? 'true' : 'false');
  }

  Future<bool> hasSelectedLanguage() async {
    final val = await getSetting('has_selected_language');
    return val == 'true';
  }

  Future<bool> hasSeenGuide() async {
    final val = await getSetting('has_seen_guide');
    return val == 'true';
  }

  Future<int> getResetCount() async {
    final val = await getSetting('data_reset_count');
    if (val != null) {
      return int.tryParse(val) ?? 0;
    }
    return _webResetCount;
  }

  Future<void> incrementResetCount() async {
    final count = await getResetCount();
    final newCount = count + 1;
    _webResetCount = newCount;
    await setSetting('data_reset_count', newCount.toString());
  }

  // ==========================================
  // 7. FAVORİ BEBEK İSİMLERİ (FAVORITE BABY NAMES)
  // ==========================================

  Future<void> _ensureFavoriteNamesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_names (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        gender TEXT NOT NULL,
        origin TEXT NOT NULL,
        meaning TEXT NOT NULL,
        characteristics TEXT NOT NULL,
        cultural_note TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<List<BabyNameModel>> getFavoriteNames() async {
    final db = await database;
    if (db == null) {
      return List.unmodifiable(_webFavoriteNames);
    }
    try {
      await _ensureFavoriteNamesTable(db);
      final maps = await db.query('favorite_names', orderBy: 'id DESC');
      final list = maps.map((m) => BabyNameModel.fromMap(m)).toList();
      _webFavoriteNames.clear();
      _webFavoriteNames.addAll(list);
      return list;
    } catch (e) {
      debugPrint('getFavoriteNames error: $e');
      return _webFavoriteNames;
    }
  }

  Future<bool> isNameFavorite(String name) async {
    final db = await database;
    if (db == null) {
      return _webFavoriteNames.any((n) => n.name == name);
    }
    try {
      await _ensureFavoriteNamesTable(db);
      final res = await db.query(
        'favorite_names',
        where: 'name = ?',
        whereArgs: [name],
        limit: 1,
      );
      return res.isNotEmpty;
    } catch (e) {
      debugPrint('isNameFavorite error: $e');
      return _webFavoriteNames.any((n) => n.name == name);
    }
  }

  Future<bool> toggleFavoriteName(BabyNameModel babyName) async {
    final currentlyFav = await isNameFavorite(babyName.name);
    final db = await database;
    if (currentlyFav) {
      // Favoriden çıkar
      _webFavoriteNames.removeWhere((n) => n.name == babyName.name);
      if (db != null) {
        try {
          await _ensureFavoriteNamesTable(db);
          await db.delete('favorite_names', where: 'name = ?', whereArgs: [babyName.name]);
        } catch (e) {
          debugPrint('removeFavoriteName error: $e');
        }
      }
      notifyDataChanged();
      return false;
    } else {
      // Favoriye ekle
      final favItem = babyName.copyWith(isFavorite: true);
      _webFavoriteNames.removeWhere((n) => n.name == babyName.name);
      _webFavoriteNames.insert(0, favItem);
      if (db != null) {
        try {
          await _ensureFavoriteNamesTable(db);
          final map = favItem.toMap();
          map.remove('id');
          await db.insert('favorite_names', map, conflictAlgorithm: ConflictAlgorithm.replace);
        } catch (e) {
          debugPrint('addFavoriteName error: $e');
        }
      }
      notifyDataChanged();
      return true;
    }
  }

  Future<void> removeFavoriteName(String name) async {
    _webFavoriteNames.removeWhere((n) => n.name == name);
    final db = await database;
    if (db != null) {
      try {
        await _ensureFavoriteNamesTable(db);
        await db.delete('favorite_names', where: 'name = ?', whereArgs: [name]);
      } catch (e) {
        debugPrint('removeFavoriteName error: $e');
      }
    }
    notifyDataChanged();
  }

  Future<void> clearAllData({bool preserveResetCount = true}) async {
    int currentResetCount = 0;
    if (preserveResetCount) {
      currentResetCount = await getResetCount();
    }
    _webProfile = null;
    _webSettings.clear();
    _webDiaries.clear();
    _webDailyLogs.clear();
    _webNotifications.clear();
    _webMedications.clear();
    _webEmergencyCard = null;
    _webFavoriteNames.clear();
    _webMedicationsSeeded = false;
    final db = await database;
    if (db != null) {
      try {
        await db.delete('daily_log');
        await db.delete('diary');
        await db.delete('profile');
        await db.delete('notifications');
        await db.delete('medications');
        await db.delete('emergency_card');
        try {
          await db.delete('favorite_names');
        } catch (_) {}
        await db.delete('app_settings');
        try {
          await db.delete('hospital_bag_items');
          await db.delete('doctor_questions');
          await db.delete('future_time_capsule');
          await db.delete('birth_plan');
          await db.delete('safety_cravings');
        } catch (_) {}
        if (preserveResetCount && currentResetCount > 0) {
          await db.insert(
            'app_settings',
            {'key': 'data_reset_count', 'value': currentResetCount.toString()},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      } catch (e) {
        debugPrint('clearAllData error: $e');
      }
    }
    _webHospitalBag.clear();
    _webHospitalBagSeeded = false;
    _webDoctorQuestions.clear();
    _webDoctorQuestionsSeeded = false;
    _webTimeCapsule.clear();
    _webBirthPlan = const BirthPlanModel();
    _webSafetyFavorites.clear();
    notifyDataChanged();
  }

  // ==========================================
  // 9. DOĞUM ÇANTASI (HOSPITAL BAG) CRUD
  // ==========================================
  Future<void> _ensureHospitalBagSeeded(Database? db) async {
    if (db != null) {
      try {
        final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM hospital_bag_items');
        final count = Sqflite.firstIntValue(countResult) ?? 0;
        if (count == 0) {
          final batch = db.batch();
          for (final item in _defaultHospitalBag) {
            batch.insert('hospital_bag_items', item.toMap());
          }
          await batch.commit(noResult: true);
        }
      } catch (_) {}
    } else {
      if (!_webHospitalBagSeeded) {
        int tempId = 1;
        for (final item in _defaultHospitalBag) {
          _webHospitalBag.add(item.copyWith(id: tempId++));
        }
        _webHospitalBagSeeded = true;
      }
    }
  }

  static const List<HospitalBagItem> _defaultHospitalBag = [
    // Anne
    HospitalBagItem(category: 'mom', title: 'Önden açılan lohusa geceliği / pijama (2 takım)'),
    HospitalBagItem(category: 'mom', title: 'Emzirme sütyeni & yıkanabilir göğüs pedleri'),
    HospitalBagItem(category: 'mom', title: 'Göğüs ucu bakım kremi (Lanolin)'),
    HospitalBagItem(category: 'mom', title: 'Organik pamuklu lohusa pedi (büyük boy)'),
    HospitalBagItem(category: 'mom', title: 'Kaymayan yumuşak terlik & kalın sıcak çorap'),
    HospitalBagItem(category: 'mom', title: 'Kimlik, hastane kartı ve doktor doğum tercih planı'),
    HospitalBagItem(category: 'mom', title: 'Dudak nemlendiricisi & saç bandı/lastik'),
    HospitalBagItem(category: 'mom', title: 'Diş fırçası, macun & seyahat boy şampuan'),
    // Bebek
    HospitalBagItem(category: 'baby', title: 'Yenidoğan hastane çıkış seti (zıbın, tulum, şapka, eldiven)'),
    HospitalBagItem(category: 'baby', title: 'Yenidoğan bebek bezi (1 paket mini boy)'),
    HospitalBagItem(category: 'baby', title: 'Yumuşak müslin örtü & pamuklu kundak battaniyesi'),
    HospitalBagItem(category: 'baby', title: 'Alkolsüz yenidoğan ıslak mendili / pamuk'),
    HospitalBagItem(category: 'baby', title: 'Doğal pişik önleyici krem'),
    HospitalBagItem(category: 'baby', title: 'Yenidoğan anakucağı / oto koltuğu (hastane çıkışı için)'),
    // Refakatçi / Baba
    HospitalBagItem(category: 'partner', title: 'Rahat yedek tişört & eşofman altı'),
    HospitalBagItem(category: 'partner', title: 'Uzun kablolu telefon şarj aleti & powerbank'),
    HospitalBagItem(category: 'partner', title: 'Sağlıklı atıştırmalıklar (kuruyemiş, meyve barları)'),
    HospitalBagItem(category: 'partner', title: 'Termos matarada taze su'),
    HospitalBagItem(category: 'partner', title: 'Otopark ve otomat için nakit bozuk para'),
  ];

  Future<List<HospitalBagItem>> getHospitalBagItems({String? category}) async {
    final db = await database;
    await _ensureHospitalBagSeeded(db);
    if (db != null) {
      try {
        final List<Map<String, dynamic>> maps;
        if (category != null) {
          maps = await db.query('hospital_bag_items', where: 'category = ?', whereArgs: [category]);
        } else {
          maps = await db.query('hospital_bag_items');
        }
        return maps.map((m) => HospitalBagItem.fromMap(m)).toList();
      } catch (e) {
        debugPrint('getHospitalBagItems error: $e');
      }
    }
    if (category != null) {
      return _webHospitalBag.where((i) => i.category == category).toList();
    }
    return List.unmodifiable(_webHospitalBag);
  }

  Future<int> insertHospitalBagItem(HospitalBagItem item) async {
    final db = await database;
    if (db != null) {
      try {
        final id = await db.insert('hospital_bag_items', item.toMap());
        notifyDataChanged();
        return id;
      } catch (e) {
        debugPrint('insertHospitalBagItem error: $e');
      }
    }
    final newId = _webHospitalBag.length + 1;
    final newItem = item.copyWith(id: newId);
    _webHospitalBag.add(newItem);
    notifyDataChanged();
    return newId;
  }

  Future<void> toggleHospitalBagItem(int id, bool isPacked) async {
    final db = await database;
    if (db != null) {
      try {
        await db.update(
          'hospital_bag_items',
          {'is_packed': isPacked ? 1 : 0},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        debugPrint('toggleHospitalBagItem error: $e');
      }
    }
    final index = _webHospitalBag.indexWhere((i) => i.id == id);
    if (index != -1) {
      _webHospitalBag[index] = _webHospitalBag[index].copyWith(isPacked: isPacked);
    }
    notifyDataChanged();
  }

  Future<void> deleteHospitalBagItem(int id) async {
    final db = await database;
    if (db != null) {
      try {
        await db.delete('hospital_bag_items', where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        debugPrint('deleteHospitalBagItem error: $e');
      }
    }
    _webHospitalBag.removeWhere((i) => i.id == id);
    notifyDataChanged();
  }

  // ==========================================
  // 10. DOKTORA SORULACAK SORULAR (DOCTOR VAULT) CRUD
  // ==========================================
  Future<void> _ensureDoctorQuestionsSeeded(Database? db) async {
    if (db != null) {
      try {
        final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM doctor_questions');
        final count = Sqflite.firstIntValue(countResult) ?? 0;
        if (count == 0) {
          final batch = db.batch();
          for (int t = 1; t <= 3; t++) {
            for (final q in DoctorQuestionsData.getPredefinedQuestions(t)) {
              batch.insert('doctor_questions', q.toMap());
            }
          }
          await batch.commit(noResult: true);
        }
      } catch (_) {}
    } else {
      if (!_webDoctorQuestionsSeeded) {
        int idGen = 1;
        for (int t = 1; t <= 3; t++) {
          for (final q in DoctorQuestionsData.getPredefinedQuestions(t)) {
            _webDoctorQuestions.add(q.copyWith(id: idGen++));
          }
        }
        _webDoctorQuestionsSeeded = true;
      }
    }
  }

  Future<List<DoctorQuestion>> getDoctorQuestions({int? trimester}) async {
    final db = await database;
    await _ensureDoctorQuestionsSeeded(db);
    if (db != null) {
      try {
        final List<Map<String, dynamic>> maps;
        if (trimester != null) {
          maps = await db.query('doctor_questions', where: 'trimester = ?', whereArgs: [trimester]);
        } else {
          maps = await db.query('doctor_questions');
        }
        return maps.map((m) => DoctorQuestion.fromMap(m)).toList();
      } catch (e) {
        debugPrint('getDoctorQuestions error: $e');
      }
    }
    if (trimester != null) {
      return _webDoctorQuestions.where((q) => q.trimester == trimester).toList();
    }
    return List.unmodifiable(_webDoctorQuestions);
  }

  Future<int> insertDoctorQuestion(DoctorQuestion question) async {
    final db = await database;
    if (db != null) {
      try {
        final id = await db.insert('doctor_questions', question.toMap());
        notifyDataChanged();
        return id;
      } catch (e) {
        debugPrint('insertDoctorQuestion error: $e');
      }
    }
    final newId = _webDoctorQuestions.length + 1;
    _webDoctorQuestions.add(question.copyWith(id: newId));
    notifyDataChanged();
    return newId;
  }

  Future<void> updateDoctorQuestionAnswer(int id, String answer, bool isAnswered) async {
    final db = await database;
    if (db != null) {
      try {
        await db.update(
          'doctor_questions',
          {'answer_note': answer, 'is_answered': isAnswered ? 1 : 0},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        debugPrint('updateDoctorQuestionAnswer error: $e');
      }
    }
    final idx = _webDoctorQuestions.indexWhere((q) => q.id == id);
    if (idx != -1) {
      _webDoctorQuestions[idx] = _webDoctorQuestions[idx].copyWith(
        answerNote: answer,
        isAnswered: isAnswered,
      );
    }
    notifyDataChanged();
  }

  Future<void> deleteDoctorQuestion(int id) async {
    final db = await database;
    if (db != null) {
      try {
        await db.delete('doctor_questions', where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        debugPrint('deleteDoctorQuestion error: $e');
      }
    }
    _webDoctorQuestions.removeWhere((q) => q.id == id);
    notifyDataChanged();
  }

  // ==========================================
  // 11. KİŞİSEL DOĞUM PLANI CRUD
  // ==========================================
  Future<BirthPlanModel> getBirthPlan() async {
    final db = await database;
    if (db != null) {
      try {
        final maps = await db.query('birth_plan', where: 'id = 1');
        if (maps.isNotEmpty) {
          return BirthPlanModel.fromMap(maps.first);
        }
      } catch (e) {
        debugPrint('getBirthPlan error: $e');
      }
    }
    return _webBirthPlan;
  }

  Future<void> saveBirthPlan(BirthPlanModel plan) async {
    final db = await database;
    final map = plan.toMap()..['id'] = 1;
    if (db != null) {
      try {
        await db.insert('birth_plan', map, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        debugPrint('saveBirthPlan error: $e');
      }
    }
    _webBirthPlan = plan;
    notifyDataChanged();
  }

  // ==========================================
  // 12. 18. YAŞ DİJİTAL ZAMAN KAPSÜLÜ CRUD
  // ==========================================
  Future<List<TimeCapsuleLetter>> getTimeCapsuleLetters() async {
    final db = await database;
    if (db != null) {
      try {
        final maps = await db.query('future_time_capsule', orderBy: 'created_date DESC');
        return maps.map((m) => TimeCapsuleLetter.fromMap(m)).toList();
      } catch (e) {
        debugPrint('getTimeCapsuleLetters error: $e');
      }
    }
    return List.unmodifiable(_webTimeCapsule);
  }

  Future<int> insertTimeCapsuleLetter(TimeCapsuleLetter letter) async {
    final db = await database;
    if (db != null) {
      try {
        final id = await db.insert('future_time_capsule', letter.toMap());
        notifyDataChanged();
        return id;
      } catch (e) {
        debugPrint('insertTimeCapsuleLetter error: $e');
      }
    }
    final newId = _webTimeCapsule.length + 1;
    _webTimeCapsule.insert(0, letter.copyWith(id: newId));
    notifyDataChanged();
    return newId;
  }

  Future<void> deleteTimeCapsuleLetter(int id) async {
    final db = await database;
    if (db != null) {
      try {
        await db.delete('future_time_capsule', where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        debugPrint('deleteTimeCapsuleLetter error: $e');
      }
    }
    _webTimeCapsule.removeWhere((l) => l.id == id);
    notifyDataChanged();
  }

  // ==========================================
  // 13. GÜVENLİK RADARI AŞERME FAVORİLERİ
  // ==========================================
  Future<Set<String>> getSafetyFavorites() async {
    final db = await database;
    if (db != null) {
      try {
        final maps = await db.query('safety_cravings');
        return maps.map((m) => m['item_id'] as String).toSet();
      } catch (e) {
        debugPrint('getSafetyFavorites error: $e');
      }
    }
    return Set.unmodifiable(_webSafetyFavorites);
  }

  Future<bool> toggleSafetyFavorite(String itemId) async {
    final db = await database;
    final isFav = _webSafetyFavorites.contains(itemId);
    if (isFav) {
      _webSafetyFavorites.remove(itemId);
      if (db != null) {
        try {
          await db.delete('safety_cravings', where: 'item_id = ?', whereArgs: [itemId]);
        } catch (_) {}
      }
    } else {
      _webSafetyFavorites.add(itemId);
      if (db != null) {
        try {
          await db.insert('safety_cravings', {'item_id': itemId}, conflictAlgorithm: ConflictAlgorithm.replace);
        } catch (_) {}
      }
    }
    notifyDataChanged();
    return !isFav;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
