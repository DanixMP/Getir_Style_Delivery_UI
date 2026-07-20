import '../config/app_config.dart';

List<T> parseList<T>(
  dynamic data,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final raw = data is List
      ? data
      : (data is Map<String, dynamic> ? data['results'] : null);
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList();
}

/// DRF serializes DecimalField ratings as JSON strings (e.g. "4.60").
double parseDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int parseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String? mediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  final normalized = path.startsWith('/') ? path.substring(1) : path;
  return '${AppConfig.serverOrigin}/$normalized';
}
