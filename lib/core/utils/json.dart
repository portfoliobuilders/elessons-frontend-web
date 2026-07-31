/// Defensive JSON coercion helpers. Backends evolve; these keep `fromJson`
/// parsing null-safe and tolerant of int/string/double drift.
class Json {
  Json._();

  static String str(dynamic v, [String fallback = '']) =>
      v == null ? fallback : v.toString();

  static String? strOrNull(dynamic v) => v?.toString();

  static int intVal(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static int? intOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double dbl(dynamic v, [double fallback = 0]) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static bool boolVal(dynamic v, [bool fallback = false]) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is int) return v != 0;
    return fallback;
  }

  static DateTime? dateOrNull(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static Map<String, dynamic> obj(dynamic v) =>
      v is Map<String, dynamic> ? v : <String, dynamic>{};

  static List<Map<String, dynamic>> list(dynamic v) {
    if (v is List) {
      return v.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }
}
