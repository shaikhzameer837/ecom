import 'package:get_storage/get_storage.dart';

import '../core/constants/app_constants.dart';

/// Thin typed wrapper over GetStorage. All local persistence goes through
/// here so keys stay in one place.
class LocalStorageService {
  final GetStorage _box = GetStorage();

  static Future<void> init() => GetStorage.init();

  // Language
  String? get languageCode => _box.read<String>(AppConstants.keyLanguage);
  Future<void> setLanguageCode(String code) =>
      _box.write(AppConstants.keyLanguage, code);

  // Theme
  String? get themeMode => _box.read<String>(AppConstants.keyThemeMode);
  Future<void> setThemeMode(String mode) =>
      _box.write(AppConstants.keyThemeMode, mode);

  // Recent searches (local-first for instant suggestions)
  List<String> get recentSearches =>
      (_box.read<List<dynamic>>(AppConstants.keyRecentSearches) ?? [])
          .map((e) => e.toString())
          .toList();

  Future<void> addRecentSearch(String query) {
    final term = query.trim();
    if (term.isEmpty) return Future.value();
    final searches = recentSearches..removeWhere((s) => s == term);
    searches.insert(0, term);
    return _box.write(AppConstants.keyRecentSearches,
        searches.take(AppConstants.maxRecentSearches).toList());
  }

  Future<void> clearRecentSearches() =>
      _box.remove(AppConstants.keyRecentSearches);

  // FCM token cache
  String? get fcmToken => _box.read<String>(AppConstants.keyFcmToken);
  Future<void> setFcmToken(String token) =>
      _box.write(AppConstants.keyFcmToken, token);

  // Dev OTP-bypass session (no Firebase Auth): persists the synthetic uid and
  // phone so the "login" survives app restarts.
  String? get bypassUid => _box.read<String>(AppConstants.keyBypassUid);
  String? get bypassPhone => _box.read<String>(AppConstants.keyBypassPhone);
  Future<void> setBypassSession(String uid, String phone) async {
    await _box.write(AppConstants.keyBypassUid, uid);
    await _box.write(AppConstants.keyBypassPhone, phone);
  }

  Future<void> clearBypassSession() async {
    await _box.remove(AppConstants.keyBypassUid);
    await _box.remove(AppConstants.keyBypassPhone);
  }

  Future<void> clearUserData() async {
    await _box.remove(AppConstants.keyRecentSearches);
    await _box.remove(AppConstants.keyFcmToken);
  }
}
