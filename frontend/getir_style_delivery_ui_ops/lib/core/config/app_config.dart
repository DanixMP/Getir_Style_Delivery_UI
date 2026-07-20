import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const _apiOverride = String.fromEnvironment('API_BASE_URL');
  static const betaApiBaseUrl = 'https://getir_style_delivery_ui.parinox.ir/api/v1';

  static String get apiBaseUrl {
    if (_apiOverride.isNotEmpty) return _apiOverride;
    if (kDebugMode) {
      if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8000/api/v1';
      }
      return 'http://127.0.0.1:8000/api/v1';
    }
    return betaApiBaseUrl;
  }

  static String get serverOrigin =>
      apiBaseUrl.replaceFirst('/api/v1', '');

  static const defaultCity = 'Tehran';

  // Neshan service key (used for the Static Map image in the tracking screen).
  // Routing goes through our backend proxy so this is only for map tiles/image.
  static const neshanKey = 'service.fb041db1b85f4b7aa01eceefef0708f8';
}
