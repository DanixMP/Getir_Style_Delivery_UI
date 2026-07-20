import 'package:flutter/material.dart';

import '../core/theme/getir_style_delivery_ui_colors.dart';

/// Neutral placeholder brand mark (no real logo asset).
class GetirStyleDeliveryUiLogoMark extends StatelessWidget {
  const GetirStyleDeliveryUiLogoMark({
    super.key,
    this.size = 1,
    this.showTagline = false,
    this.tagline,
    this.onDarkBackground = true,
  });

  /// Scale factor for the whole mark (1 = default splash size).
  final double size;
  final bool showTagline;
  final String? tagline;

  /// When true, uses light ink for dark/primary surfaces (splash).
  /// When false, uses primary ink for light surfaces (login).
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final ink = onDarkBackground
        ? GetirStyleDeliveryUiColors.onPrimary
        : GetirStyleDeliveryUiColors.primary;
    final boxFill = onDarkBackground
        ? GetirStyleDeliveryUiColors.surfaceContainerLowest.withValues(alpha: 0.22)
        : GetirStyleDeliveryUiColors.primaryFixed;
    final boxBorder = ink.withValues(alpha: onDarkBackground ? 0.35 : 0.2);

    final iconBox = 72.0 * size;
    final iconSize = 36.0 * size;
    final wordSize = 22.0 * size;
    final tagSize = 14.0 * size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: boxFill,
                borderRadius: BorderRadius.circular(18 * size),
                border: Border.all(color: boxBorder, width: 1.5 * size),
              ),
              child: SizedBox(
                width: iconBox,
                height: iconBox,
                child: Icon(
                  Icons.image_outlined,
                  size: iconSize,
                  color: ink.withValues(alpha: 0.9),
                ),
              ),
            ),
            SizedBox(width: 14 * size),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOGO',
                  style: TextStyle(
                    fontSize: wordSize,
                    fontWeight: FontWeight.w800,
                    color: ink,
                    height: 1,
                    letterSpacing: 2 * size,
                  ),
                ),
                SizedBox(height: 4 * size),
                Text(
                  'PLACEHOLDER',
                  style: TextStyle(
                    fontSize: wordSize * 0.55,
                    fontWeight: FontWeight.w600,
                    color: ink.withValues(alpha: 0.65),
                    height: 1,
                    letterSpacing: 1.2 * size,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (showTagline && tagline != null) ...[
          SizedBox(height: 18 * size),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: tagSize,
              fontWeight: FontWeight.w500,
              color: ink.withValues(alpha: 0.72),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
