/// Non-web platforms: real GPS requires the geolocator package once pub.dev is reachable.
Future<({double lat, double lng})?> readDevicePosition() async => null;
