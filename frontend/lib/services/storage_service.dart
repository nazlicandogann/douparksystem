import 'package:shared_preferences/shared_preferences.dart';

/// Kalıcı yerel depolama servisi
/// Web ve mobil uyumlu - SharedPreferences kullanır
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── ARAÇLAR ──────────────────────────────────────────────────────────────
  static Future<void> saveVehicles(String email, List<String> plates) async {
    await init();
    await _prefs!.setStringList('vehicles_$email', plates);
  }

  static Future<List<String>> loadVehicles(String email) async {
    await init();
    return _prefs!.getStringList('vehicles_$email') ?? [];
  }

  // ── YAPTIRИМ SAYACI ──────────────────────────────────────────────────────
  static Future<void> saveNoShowCount(String email, int count) async {
    await init();
    await _prefs!.setInt('noshow_$email', count);
  }

  static Future<int> loadNoShowCount(String email) async {
    await init();
    return _prefs!.getInt('noshow_$email') ?? 0;
  }

  static Future<void> saveBanned(String email, bool banned) async {
    await init();
    await _prefs!.setBool('banned_$email', banned);
  }

  static Future<bool> loadBanned(String email) async {
    await init();
    return _prefs!.getBool('banned_$email') ?? false;
  }

  // ── REZERVASYON SAYACI ───────────────────────────────────────────────────
  static Future<void> saveReservationCount(String email, int count) async {
    await init();
    await _prefs!.setInt('rescount_$email', count);
  }

  static Future<int> loadReservationCount(String email) async {
    await init();
    return _prefs!.getInt('rescount_$email') ?? 0;
  }

  // ── TOPLAM HARCAMA ───────────────────────────────────────────────────────
  static Future<void> saveTotalSpent(String email, double amount) async {
    await init();
    await _prefs!.setDouble('spent_$email', amount);
  }

  static Future<double> loadTotalSpent(String email) async {
    await init();
    return _prefs!.getDouble('spent_$email') ?? 0.0;
  }

  // ── GENEL ────────────────────────────────────────────────────────────────
  // ── TELEFON ──────────────────────────────────────────────────────────────
  static Future<void> savePhone(String email, String phone) async {
    await init();
    await _prefs!.setString('phone_$email', phone);
  }

  static Future<String> loadPhone(String email) async {
    await init();
    return _prefs!.getString('phone_$email') ?? '';
  }

  static Future<void> clearUser(String email) async {
    await init();
    await _prefs!.remove('noshow_$email');
    await _prefs!.remove('banned_$email');
    await _prefs!.remove('rescount_$email');
    await _prefs!.remove('spent_$email');
    await _prefs!.remove('phone_$email');
    await _prefs!.remove('vehicles_$email');
  }
}
