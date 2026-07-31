import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

/// Central runtime configuration.
class AppConfig {
  AppConfig._();

  static const Environment environment = Environment.development;

  /// Primary backend API base URL.
  static const String apiBase = 'https://merrill-witty-doyly.ngrok-free.dev/api';

  /// Optional override via `--dart-define=BASE_URL=http://...`
  static const String _customBaseUrl = String.fromEnvironment('BASE_URL');

  static String? _manualBaseUrlOverride;
  static set manualBaseUrlOverride(String? url) => _manualBaseUrlOverride = url;

  /// Dynamic base URL getter.
  static String get baseUrl {
    String raw = apiBase;
    if (_manualBaseUrlOverride != null && _manualBaseUrlOverride!.isNotEmpty) {
      raw = _manualBaseUrlOverride!;
    } else if (_customBaseUrl.isNotEmpty) {
      raw = _customBaseUrl;
    }
    raw = raw.trim();
    if (raw.endsWith('/')) {
      raw = raw.substring(0, raw.length - 1);
    }
    if (!raw.endsWith('/api')) {
      raw = '$raw/api';
    }
    return raw;
  }

  /// Network timeouts.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Automatic retry for idempotent GETs on transient network failures.
  static const int maxRetries = 2;
  static const Duration retryBackoff = Duration(milliseconds: 600);

  /// Verbose request/response logging (disabled in release builds).
  static const bool enableLogging = !kReleaseMode;

  /// Region / currency defaults mirror the backend's DEFAULT_REGION / DEFAULT_CURRENCY.
  static const String defaultRegion = 'IN';
  static const String defaultCurrency = 'INR';
  static const String defaultBoard = 'CBSE';
}
