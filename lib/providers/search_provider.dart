import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/storage/local_storage_service.dart';
import '../models/api/search.dart';
import '../repositories/search_repository.dart';
import 'view_status.dart';

/// Search state. Queries under 2 chars are ignored (mirrors the backend).
class SearchProvider extends ChangeNotifier {
  SearchProvider(this._repo, {LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  final SearchRepository _repo;
  final LocalStorageService _storage;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  SearchResults _results = SearchResults.empty;
  SearchResults get results => _results;

  String _query = '';
  String get query => _query;

  List<String> get recent => _storage.recentSearches;

  Future<void> search(String q) async {
    _query = q;
    if (q.trim().length < 2) {
      _results = SearchResults.empty;
      _status = ViewStatus.idle;
      notifyListeners();
      return;
    }
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _results = await _repo.search(q.trim());
      await _storage.addRecentSearch(q.trim());
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = SearchResults.empty;
    _status = ViewStatus.idle;
    notifyListeners();
  }
}
