import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/account_repository.dart';
import '../../data/repositories/tracking_repository.dart';
import '../location/position_reader.dart';

/// Streams the peyk's GPS to the backend while "online", and marks the
/// peyk available/unavailable on the server so operators see them in realtime.
class LocationProvider extends ChangeNotifier {
  LocationProvider(this._tracking, this._account);

  final TrackingRepository _tracking;
  final AccountRepository _account;

  double _lat = 35.6892;
  double _lng = 51.3890;

  bool _online = false;
  bool _sending = false;
  String? _activeOrderId;
  DateTime? _lastSentAt;
  String? _error;
  Timer? _timer;

  bool get online => _online;
  double get latitude => _lat;
  double get longitude => _lng;
  DateTime? get lastSentAt => _lastSentAt;
  String? get error => _error;

  void setActiveOrder(String? orderId) => _activeOrderId = orderId;

  Future<void> goOnline() async {
    if (_online) return;
    _online = true;
    _error = null;
    notifyListeners();
    try {
      await _account.setAvailability(true);
    } catch (_) {/* non-fatal */}
    await _sendOnce();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _sendOnce());
  }

  void goOffline() {
    _online = false;
    _timer?.cancel();
    _timer = null;
    _account.setAvailability(false).catchError((_) {});
    notifyListeners();
  }

  Future<void> toggle() => _online ? Future.sync(goOffline) : goOnline();

  Future<void> _sendOnce() async {
    if (!_online || _sending) return;
    _sending = true;
    try {
      final pos = await readDevicePosition();
      if (pos != null) {
        _lat = pos.lat;
        _lng = pos.lng;
        _error = null;
      } else if (kIsWeb) {
        _error = 'دسترسی به موقعیت مرورگر را فعال کنید.';
      }
      await _tracking.postLocation(
        latitude: double.parse(_lat.toStringAsFixed(6)),
        longitude: double.parse(_lng.toStringAsFixed(6)),
        orderId: _activeOrderId,
      );
      _lastSentAt = DateTime.now();
    } catch (_) {
      _error = 'ارسال موقعیت ناموفق بود.';
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
