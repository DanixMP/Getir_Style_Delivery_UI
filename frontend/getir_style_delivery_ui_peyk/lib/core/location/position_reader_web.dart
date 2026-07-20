// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

/// Browser Geolocation API — used for the peyk web app during development.
Future<({double lat, double lng})?> readDevicePosition() async {
  try {
    final pos = await html.window.navigator.geolocation
        .getCurrentPosition(enableHighAccuracy: true)
        .timeout(const Duration(seconds: 8));
    return (
      lat: pos.coords!.latitude!.toDouble(),
      lng: pos.coords!.longitude!.toDouble(),
    );
  } catch (_) {
    return null;
  }
}
