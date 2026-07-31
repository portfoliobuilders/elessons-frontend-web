import 'package:flutter/foundation.dart';

import '../core/storage/local_storage_service.dart';

/// Lightweight app preferences (notifications toggle, recent searches).
/// Backed by SharedPreferences via [LocalStorageService].
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  final LocalStorageService _storage;

  bool get notificationsEnabled => _storage.notificationsEnabled;

  Future<void> setNotificationsEnabled(bool value) async {
    await _storage.setNotificationsEnabled(value);
    notifyListeners();
  }

  List<String> get recentSearches => _storage.recentSearches;

  Future<void> addRecentSearch(String q) async {
    await _storage.addRecentSearch(q);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    await _storage.clearRecentSearches();
    notifyListeners();
  }
}
