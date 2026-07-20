import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';

/// Neshan map tiles, polyline decoding, and map helpers.
abstract final class NeshanService {
  static const Distance _distance = Distance();

  /// Native tile URL — proxied by our backend (Neshan service keys need Api-Key header).
  static String get tileUrlTemplate =>
      '${AppConfig.apiBaseUrl}/tracking/tiles/{z}/{x}/{y}.png';

  /// Decodes a Google/Neshan "encoded polyline" string into coordinates.
  static List<LatLng> decodePolyline(String encoded) {
    if (encoded.isEmpty) return [];
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int result = 0, shift = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  /// Server-provided road geometry (preferred over overview polyline).
  static List<LatLng> parseGeometry(List<dynamic>? raw) {
    if (raw == null) return [];
    final points = <LatLng>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final lat = (item['lat'] as num?)?.toDouble();
      final lng = (item['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final pt = LatLng(lat, lng);
      if (points.isEmpty || points.last != pt) points.add(pt);
    }
    return points;
  }

  /// Pin the polyline to the live peyk position and delivery address.
  static List<LatLng> snapRouteEndpoints(
    List<LatLng> points,
    LatLng origin,
    LatLng destination,
  ) {
    if (points.isEmpty) return points;
    final snapped = List<LatLng>.from(points);
    snapped[0] = origin;
    snapped[snapped.length - 1] = destination;
    return snapped;
  }

  /// Reject coarse or mismatched polylines (e.g. wrong overview shortcuts).
  static bool routeConnects(
    LatLng origin,
    LatLng destination,
    List<LatLng> points, {
    double maxEndpointMeters = 2000,
  }) {
    if (points.length < 2) return false;
    final toOrigin = _distance.as(LengthUnit.Meter, points.first, origin);
    final toDest = _distance.as(LengthUnit.Meter, points.last, destination);
    if (toOrigin > maxEndpointMeters || toDest > maxEndpointMeters) {
      return false;
    }
    final direct = _distance.as(LengthUnit.Meter, origin, destination);
    if (direct < 80) return true;
    var pathLen = 0.0;
    for (var i = 1; i < points.length; i++) {
      pathLen += _distance.as(LengthUnit.Meter, points[i - 1], points[i]);
    }
    return pathLen <= direct * 4;
  }
}
