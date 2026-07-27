import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../storage/local_storage_service.dart';
import 'api_exception.dart';
import 'connectivity_service.dart';

/// The single HTTP gateway for the whole app.
///
/// Responsibilities:
///  - build absolute URLs from [AppConfig.baseUrl] + endpoint paths
///  - inject the `Authorization: Bearer <token>` header automatically
///  - enforce connect/receive timeouts
///  - retry idempotent GETs on transient failures
///  - log requests/responses in debug
///  - decode JSON and map non-2xx responses to typed [ApiException]s
///  - transparently refresh an expired access token on a 401 and retry once
///
/// It exposes `get/post/patch/delete/multipart`, each returning the decoded
/// JSON body (`Map`, `List`, or primitive). Repositories turn that into models.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  final LocalStorageService _storage = LocalStorageService.instance;
  final ConnectivityService _connectivity = ConnectivityService.instance;

  /// Registered by AuthProvider. Invoked when the session is irrecoverably
  /// unauthorized (refresh failed), so the app can log out + route to welcome.
  void Function()? onUnauthorized;

  /// Guards against multiple concurrent refreshes stampeding the endpoint.
  Future<bool>? _refreshInFlight;

  // ── Public verbs ────────────────────────────────────────────────────

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) {
    return _send(
      method: 'GET',
      path: path,
      query: query,
      auth: auth,
      idempotent: true,
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool auth = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      query: query,
      auth: auth,
    );
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    bool auth = true,
  }) {
    return _send(method: 'PATCH', path: path, body: body, auth: auth);
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    bool auth = true,
  }) {
    return _send(method: 'DELETE', path: path, body: body, auth: auth);
  }

  /// Multipart upload (e.g. profile photo). [fields] carries text parts and
  /// [files] carries file parts keyed by their form field name.
  Future<dynamic> multipart(
    String path, {
    required Map<String, String> fields,
    required Map<String, File> files,
    String method = 'POST',
    bool auth = true,
  }) async {
    await _ensureOnline();
    final uri = _uri(path);
    final request = http.MultipartRequest(method, uri)
      ..fields.addAll(fields);
    for (final entry in files.entries) {
      request.files
          .add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
    }
    if (auth) {
      final token = _storage.accessToken;
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
    }

    _log('→ $method $uri (multipart: ${files.keys.join(', ')})');
    try {
      final streamed =
          await request.send().timeout(AppConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response, method: method, uri: uri);
    } on SocketException {
      throw ApiException.noInternet();
    } on TimeoutException {
      throw ApiException.timeout();
    }
  }

  // ── Core send with retry + refresh ──────────────────────────────────

  Future<dynamic> _send({
    required String method,
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    bool auth = true,
    bool idempotent = false,
    int attempt = 0,
    bool didRefresh = false,
  }) async {
    await _ensureOnline();
    final uri = _uri(path, query);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
      'ngrok-skip-browser-warning': 'true',
    };
    if (auth) {
      final token = _storage.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final encodedBody = body == null ? null : jsonEncode(body);

    _log('→ $method $uri${encodedBody != null ? ' body=$encodedBody' : ''}');

    try {
      final http.Response response;
      switch (method) {
        case 'GET':
          response = await _http
              .get(uri, headers: headers)
              .timeout(AppConfig.receiveTimeout);
          break;
        case 'POST':
          response = await _http
              .post(uri, headers: headers, body: encodedBody)
              .timeout(AppConfig.receiveTimeout);
          break;
        case 'PATCH':
          response = await _http
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(AppConfig.receiveTimeout);
          break;
        case 'DELETE':
          response = await _http
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(AppConfig.receiveTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      // Transparent refresh: on a 401 for an authed request, try once to
      // refresh the access token and replay the original request.
      if (response.statusCode == 401 &&
          auth &&
          !didRefresh &&
          _storage.refreshToken != null) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          return _send(
            method: method,
            path: path,
            body: body,
            query: query,
            auth: auth,
            idempotent: idempotent,
            attempt: attempt,
            didRefresh: true,
          );
        } else {
          onUnauthorized?.call();
        }
      }

      return _handleResponse(response, method: method, uri: uri);
    } on SocketException {
      if (idempotent && attempt < AppConfig.maxRetries) {
        await Future<void>.delayed(AppConfig.retryBackoff * (attempt + 1));
        return _send(
          method: method,
          path: path,
          body: body,
          query: query,
          auth: auth,
          idempotent: idempotent,
          attempt: attempt + 1,
          didRefresh: didRefresh,
        );
      }
      throw ApiException.noInternet();
    } on TimeoutException {
      if (idempotent && attempt < AppConfig.maxRetries) {
        await Future<void>.delayed(AppConfig.retryBackoff * (attempt + 1));
        return _send(
          method: method,
          path: path,
          body: body,
          query: query,
          auth: auth,
          idempotent: idempotent,
          attempt: attempt + 1,
          didRefresh: didRefresh,
        );
      }
      throw ApiException.timeout();
    } on http.ClientException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('failed to fetch') || msg.contains('xmlhttprequest')) {
        if (idempotent && attempt < AppConfig.maxRetries) {
          await Future<void>.delayed(AppConfig.retryBackoff * (attempt + 1));
          return _send(
            method: method,
            path: path,
            body: body,
            query: query,
            auth: auth,
            idempotent: idempotent,
            attempt: attempt + 1,
            didRefresh: didRefresh,
          );
        }
        throw ApiException('Server unavailable. Please check your connection and try again.',
            kind: ApiErrorKind.server);
      }
      throw ApiException('Network unavailable: ${e.message}',
          kind: ApiErrorKind.noInternet);
    }
  }

  /// Calls POST /auth/refresh with the stored refresh token, persists the new
  /// pair, and returns whether it succeeded. Concurrent callers share one call.
  Future<bool> _refreshToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _doRefresh() async {
    final refreshToken = _storage.refreshToken;
    if (refreshToken == null) return false;
    try {
      final uri = _uri(ApiEndpoints.refresh);
      final response = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(AppConfig.receiveTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final access = data['accessToken'] as String?;
        final refresh = data['refreshToken'] as String?;
        if (access != null && refresh != null) {
          await _storage.saveTokens(accessToken: access, refreshToken: refresh);
          _log('↻ token refreshed');
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  Future<void> _ensureOnline() async {
    final online = await _connectivity.hasConnection();
    if (!online) throw ApiException.noInternet();
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('${AppConfig.baseUrl}$path');
    if (query == null || query.isEmpty) return base;
    final params = <String, String>{};
    query.forEach((k, v) {
      if (v != null) params[k] = v.toString();
    });
    return base.replace(queryParameters: {...base.queryParameters, ...params});
  }

  dynamic _handleResponse(
    http.Response response, {
    required String method,
    required Uri uri,
  }) {
    final status = response.statusCode;
    final bodyText = response.body;
    _log('← $status $method $uri (${bodyText.length}b)');

    dynamic decoded;
    if (bodyText.isNotEmpty) {
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        // Non-JSON body. For 2xx that's still acceptable (e.g. empty string);
        // for errors, surface a parsing error.
        if (status >= 200 && status < 300) return bodyText;
        throw ApiException.parsing('Non-JSON error body: '
            '${bodyText.length > 200 ? '${bodyText.substring(0, 200)}…' : bodyText}');
      }
    }

    if (status >= 200 && status < 300) {
      return decoded;
    }
    throw ApiException.fromResponse(status, decoded);
  }

  void _log(String message) {
    if (AppConfig.enableLogging) {
      developer.log(message, name: 'ApiClient');
    }
  }

  void dispose() => _http.close();
}
