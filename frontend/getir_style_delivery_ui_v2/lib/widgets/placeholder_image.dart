import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/getir_style_delivery_ui_colors.dart';
import '../core/theme/getir_style_delivery_ui_radius.dart';

/// Displays a local asset or remote image with a themed fallback.
///
/// Remote images are cached on disk + in memory (via cached_network_image) and
/// decoded at a bounded resolution so large catalog photos don't blow up the
/// image cache or cause scroll jank.
class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackColor,
    this.borderRadius,
  });

  final String? assetPath;
  final String? networkUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final BorderRadius? borderRadius;

  /// Upper bound for decoded width when the display size is unknown. Keeps
  /// full-bleed/cover images from being decoded at their native resolution.
  static const int _maxDecodeWidth = 1000;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(GetirStyleDeliveryUiRadius.md);
    final url = networkUrl;
    if (url != null && url.isNotEmpty) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final cacheWidth = (width != null && width!.isFinite)
          ? (width! * dpr).round()
          : _maxDecodeWidth;
      return ClipRRect(
        borderRadius: radius,
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: cacheWidth,
          maxWidthDiskCache: _maxDecodeWidth,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (_, __) => _loading(radius),
          errorWidget: (_, __, ___) => _fallback(radius),
        ),
      );
    }
    if (assetPath != null && assetPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          assetPath!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _fallback(radius),
        ),
      );
    }
    return _fallback(radius);
  }

  Widget _loading(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLow,
        borderRadius: radius,
      ),
    );
  }

  Widget _fallback(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: GetirStyleDeliveryUiColors.surfaceContainerLow,
        borderRadius: radius,
      ),
      child: Icon(
        fallbackIcon,
        size: (width != null && height != null)
            ? (width! < height! ? width! : height!) * 0.4
            : 32,
        color: fallbackColor ?? GetirStyleDeliveryUiColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
