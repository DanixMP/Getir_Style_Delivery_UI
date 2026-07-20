import 'package:latlong2/latlong.dart';

import '../../core/network/api_client.dart';
import '../../core/network/neshan_service.dart';
import '../../data/models/neshan_reverse_result.dart';
import '../../data/models/neshan_search_result.dart';

class RouteResult {
  const RouteResult({
    required this.points,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.durationText,
    required this.distanceText,
  });

  final List<LatLng> points;
  final int durationSeconds;
  final int distanceMeters;
  final String durationText;
  final String distanceText;

  int get durationMinutes => (durationSeconds / 60).ceil();
}

class DistanceResult {
  const DistanceResult({
    required this.durationSeconds,
    required this.distanceMeters,
    required this.durationText,
    required this.distanceText,
  });

  final int durationSeconds;
  final int distanceMeters;
  final String durationText;
  final String distanceText;

  int get durationMinutes => (durationSeconds / 60).ceil();

  factory DistanceResult.fromJson(Map<String, dynamic> json) => DistanceResult(
        durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
        distanceMeters: (json['distance_meters'] as num?)?.toInt() ?? 0,
        durationText: json['duration_text'] as String? ?? '',
        distanceText: json['distance_text'] as String? ?? '',
      );
}

class TrackingRepository {
  TrackingRepository(this._client);

  final ApiClient _client;

  /// GET /tracking/route/ — Neshan routing with live traffic (road geometry).
  Future<RouteResult?> route(LatLng origin, LatLng destination) async {
    try {
      final resp = await _client.dio.get('/tracking/route/', queryParameters: {
        'olat': origin.latitude,
        'olng': origin.longitude,
        'dlat': destination.latitude,
        'dlng': destination.longitude,
        'type': 'motorcycle',
      });
      final data = resp.data as Map<String, dynamic>;
      final geometry = NeshanService.parseGeometry(data['geometry'] as List<dynamic>?);
      final decoded =
          NeshanService.decodePolyline(data['polyline'] as String? ?? '');
      final points = geometry.length >= 2 ? geometry : decoded;
      return RouteResult(
        points: points,
        durationSeconds: (data['duration_seconds'] as num?)?.toInt() ?? 0,
        distanceMeters: (data['distance_meters'] as num?)?.toInt() ?? 0,
        durationText: data['duration_text'] as String? ?? '',
        distanceText: data['distance_text'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  /// GET /tracking/distance/ — Neshan distance matrix (fast live ETA).
  Future<DistanceResult?> distance(LatLng origin, LatLng destination) async {
    try {
      final resp = await _client.dio.get('/tracking/distance/', queryParameters: {
        'olat': origin.latitude,
        'olng': origin.longitude,
        'dlat': destination.latitude,
        'dlng': destination.longitude,
        'type': 'motorcycle',
      });
      return DistanceResult.fromJson(resp.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// GET /tracking/reverse/ — Neshan reverse geocoding (map pin → address).
  Future<NeshanReverseResult?> reverse(LatLng point) async {
    try {
      final resp = await _client.dio.get('/tracking/reverse/', queryParameters: {
        'lat': point.latitude,
        'lng': point.longitude,
      });
      return NeshanReverseResult.fromJson(resp.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// GET /tracking/search/ — Neshan location-based place search.
  Future<List<NeshanSearchResult>> search(
    String term,
    LatLng near,
  ) async {
    if (term.trim().length < 2) return [];
    try {
      final resp = await _client.dio.get('/tracking/search/', queryParameters: {
        'term': term.trim(),
        'lat': near.latitude,
        'lng': near.longitude,
      });
      final data = resp.data as Map<String, dynamic>;
      final raw = data['results'];
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(NeshanSearchResult.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
