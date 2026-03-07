import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:ram_website/theme/theme_colors.dart';

Widget buildSectionImage({
  required String imagePath,
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  final isNetwork =
      imagePath.startsWith('http://') || imagePath.startsWith('https://');
  developer.log('buildSectionImage CALLED path=${imagePath.substring(0, imagePath.length.clamp(0, 80))}... isNetwork=$isNetwork', name: 'SectionImage');

  if (isNetwork) {
    return CustomNetworkImage(
      url: imagePath,
      fit: fit,
      width: width,
      height: height,
      enableHoverIcons: false,
      customLoadingBuilder: (context, child, progress) {
        final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
        return Container(
          color: theme.surfaceSecondary,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: errorBuilder ??
          (context, error, stackTrace) {
            developer.log('CustomNetworkImage LOAD ERROR: $error', name: 'SectionImage');
            developer.log('URL was: ${imagePath.substring(0, imagePath.length.clamp(0, 80))}...', name: 'SectionImage');
            final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
            return Container(
              color: theme.surfaceSecondary,
              child: Center(
                child: Icon(Icons.broken_image_outlined, color: theme.textSecondary),
              ),
            );
          },
    );
  }

  return Image.asset(
    imagePath,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder ??
        (context, error, stackTrace) {
          final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
          return Container(
            color: theme.surfaceSecondary,
            child: Center(
              child: Icon(Icons.broken_image_outlined, color: theme.textSecondary),
            ),
          );
        },
  );
}
