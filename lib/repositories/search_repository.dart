import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/search.dart';

/// Search (search.controller.ts). Public; requires q length >= 2.
class SearchRepository {
  SearchRepository(this._api);
  final ApiClient _api;

  Future<SearchResults> search(String query, {String? type}) async {
    final res = await _api.get(ApiEndpoints.search,
        query: {'q': query, if (type != null) 'type': type}, auth: false);
    return SearchResults.fromJson(res as Map<String, dynamic>);
  }
}
