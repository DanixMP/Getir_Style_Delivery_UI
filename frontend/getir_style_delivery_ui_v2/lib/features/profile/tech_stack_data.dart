import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A technology layer used in the GetirStyleDeliveryUi platform.
class TechStackItem {
  const TechStackItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.detail,
    required this.icon,
    required this.colors,
    required this.packages,
    required this.usedIn,
  });

  final String id;
  final String title;
  final String summary;
  final String detail;
  final IconData icon;
  final List<Color> colors;
  final List<String> packages;
  final List<String> usedIn;
}

List<TechStackItem> techStackItems(AppLocalizations l10n) => [
      TechStackItem(
        id: 'flutter',
        title: l10n.techFlutter,
        summary: l10n.techFlutterDesc,
        detail: l10n.techFlutterDetail,
        icon: Icons.flutter_dash_rounded,
        colors: const [Color(0xFF02569B), Color(0xFF13B9FD)],
        packages: const [
          'Flutter SDK 3.9',
          'provider',
          'dio',
          'flutter_map + latlong2',
          'panorama',
          'geolocator',
          'cached_network_image',
        ],
        usedIn: [
          l10n.techFlutterUse1,
          l10n.techFlutterUse2,
          l10n.techFlutterUse3,
        ],
      ),
      TechStackItem(
        id: 'django',
        title: l10n.techDjango,
        summary: l10n.techDjangoDesc,
        detail: l10n.techDjangoDetail,
        icon: Icons.dns_rounded,
        colors: const [Color(0xFF092E20), Color(0xFF44B78B)],
        packages: const [
          'Django 5',
          'Django REST Framework',
          'simplejwt',
          'django-filter',
          'django-unfold',
          'django-storages (S3)',
        ],
        usedIn: [
          l10n.techDjangoUse1,
          l10n.techDjangoUse2,
          l10n.techDjangoUse3,
        ],
      ),
      TechStackItem(
        id: 'channels',
        title: l10n.techWebSocket,
        summary: l10n.techWebSocketDesc,
        detail: l10n.techWebSocketDetail,
        icon: Icons.sync_alt_rounded,
        colors: const [Color(0xFF4520A5), Color(0xFF7C4DFF)],
        packages: const [
          'Django Channels 4',
          'channels-redis',
          'Daphne ASGI',
        ],
        usedIn: [
          l10n.techWebSocketUse1,
          l10n.techWebSocketUse2,
        ],
      ),
      TechStackItem(
        id: 'postgres',
        title: l10n.techPostgres,
        summary: l10n.techPostgresDesc,
        detail: l10n.techPostgresDetail,
        icon: Icons.storage_rounded,
        colors: const [Color(0xFF1A5276), Color(0xFF3498DB)],
        packages: const ['PostgreSQL', 'psycopg2-binary'],
        usedIn: [
          l10n.techPostgresUse1,
          l10n.techPostgresUse2,
        ],
      ),
      TechStackItem(
        id: 'redis',
        title: l10n.techRedis,
        summary: l10n.techRedisDesc,
        detail: l10n.techRedisDetail,
        icon: Icons.memory_rounded,
        colors: const [Color(0xFFB71C1C), Color(0xFFE53935)],
        packages: const [
          'Redis 5',
          'Celery',
          'django-celery-beat',
          'channels-redis',
        ],
        usedIn: [
          l10n.techRedisUse1,
          l10n.techRedisUse2,
          l10n.techRedisUse3,
        ],
      ),
      TechStackItem(
        id: 'neshan',
        title: l10n.techNeshan,
        summary: l10n.techNeshanDesc,
        detail: l10n.techNeshanDetail,
        icon: Icons.map_rounded,
        colors: const [Color(0xFFE65100), Color(0xFFFFB300)],
        packages: const [
          'Neshan Static Map v5',
          'Neshan reverse geocode API',
          'Backend tile proxy',
        ],
        usedIn: [
          l10n.techNeshanUse1,
          l10n.techNeshanUse2,
          l10n.techNeshanUse3,
        ],
      ),
      TechStackItem(
        id: 'firebase',
        title: l10n.techFirebase,
        summary: l10n.techFirebaseDesc,
        detail: l10n.techFirebaseDetail,
        icon: Icons.notifications_active_rounded,
        colors: const [Color(0xFFFF6F00), Color(0xFFFFCA28)],
        packages: const ['firebase-admin', 'FCM multicast'],
        usedIn: [
          l10n.techFirebaseUse1,
          l10n.techFirebaseUse2,
        ],
      ),
    ];
