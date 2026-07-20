/// App metadata — keep in sync with `pubspec.yaml` version.
abstract final class AppInfo {
  static const name = 'GetirStyleDeliveryUi';
  static const version = '1.0.0';
  static const buildNumber = '1';
  static const phase = 'Beta';

  static String get versionLabel => '$version ($phase)';
  static String get fullVersionLabel => '$version+$buildNumber · $phase';

  static const developerName = 'Danix';
  static const projectName = 'GetirStyleDeliveryUi B-Project v4';
}
