import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single reusable persistence layer over [SharedPreferences].
///
/// Owns the auth session (access + refresh tokens, cached user snapshot,
/// login flag) plus lightweight UI preferences (recent searches, recently
/// viewed, notifications toggle). Initialise once at app start via [init].
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  late SharedPreferences _prefs;
  bool _ready = false;

  static const _kStorageMigrationVersionKey = 'storage_migration_version_v3';
  static const int _kCurrentStorageVersion = 3; // Incremented to force wipe stale caches

  Future<void> init() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();
    _ready = true;

    await _runMigrationCheck();
  }

  Future<void> _runMigrationCheck() async {
    final int currentVersion = _prefs.getInt(_kStorageMigrationVersionKey) ?? 0;
    if (currentVersion < _kCurrentStorageVersion) {
      final token = accessToken;
      final refresh = refreshToken;
      final loggedIn = isLoggedIn;

      debugPrint('🧹 [LocalStorageService] Running one-time cache migration v$_kCurrentStorageVersion: Wiping stale cached data...');
      await _prefs.clear();

      if (loggedIn && token != null && refresh != null) {
        await _prefs.setString(_kAccessToken, token);
        await _prefs.setString(_kRefreshToken, refresh);
        await _prefs.setBool(_kLoggedIn, true);
      }

      await _prefs.setInt(_kStorageMigrationVersionKey, _kCurrentStorageVersion);
      debugPrint('✅ [LocalStorageService] Cache migration v$_kCurrentStorageVersion complete.');
    }
  }

  // ── Keys ────────────────────────────────────────────────────────────
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kLoggedIn = 'logged_in';
  static const _kUser = 'user_json';
  static const _kOnboarded = 'onboarded';
  static const _kNotificationsEnabled = 'notifications_enabled';
  static const _kRecentSearches = 'recent_searches';
  static const _kRecentlyViewed = 'recently_viewed';

  // ── Session ─────────────────────────────────────────────────────────
  String? get accessToken => _prefs.getString(_kAccessToken);
  String? get refreshToken => _prefs.getString(_kRefreshToken);
  bool get isLoggedIn => _prefs.getBool(_kLoggedIn) ?? false;
  bool get isOnboarded => _prefs.getBool(_kOnboarded) ?? false;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_kAccessToken, accessToken);
    await _prefs.setString(_kRefreshToken, refreshToken);
    await _prefs.setBool(_kLoggedIn, true);
  }

  Future<void> setOnboarded(bool value) => _prefs.setBool(_kOnboarded, value);

  /// Persist the user snapshot returned alongside the tokens.
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_kUser, jsonEncode(user));
    if (user['onboarded'] is bool) {
      await setOnboarded(user['onboarded'] as bool);
    }
  }

  Map<String, dynamic>? get user {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? get userId => user?['id'] as String?;

  /// Wipe the whole session (logout / forced 401).
  Future<void> clearSession() async {
    await _prefs.remove(_kAccessToken);
    await _prefs.remove(_kRefreshToken);
    await _prefs.remove(_kUser);
    await _prefs.setBool(_kLoggedIn, false);
    await _prefs.setBool(_kOnboarded, false);
  }

  // ── Preferences ─────────────────────────────────────────────────────
  bool get notificationsEnabled =>
      _prefs.getBool(_kNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(_kNotificationsEnabled, v);

  List<String> get recentSearches =>
      _prefs.getStringList(_kRecentSearches) ?? const [];

  Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = recentSearches.toList()..remove(q);
    list.insert(0, q);
    await _prefs.setStringList(
        _kRecentSearches, list.take(10).toList(growable: false));
  }

  Future<void> clearRecentSearches() => _prefs.remove(_kRecentSearches);

  List<String> get recentlyViewed =>
      _prefs.getStringList(_kRecentlyViewed) ?? const [];

  Future<void> addRecentlyViewed(String id) async {
    if (id.isEmpty) return;
    final list = recentlyViewed.toList()..remove(id);
    list.insert(0, id);
    await _prefs.setStringList(
        _kRecentlyViewed, list.take(20).toList(growable: false));
  }
}
