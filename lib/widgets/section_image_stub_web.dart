import 'dart:developer' as developer;
import 'dart:html' as html;
import 'dart:typed_data' as typed_data;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:ram_website/theme/theme_colors.dart';

/// Web-specific implementation. Loads assets via HTTP fetch (bypasses rootBundle
/// path bug) and displays with Image.memory.
Widget buildSectionImage({
  required String imagePath,
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  final isNetwork =
      imagePath.startsWith('http://') || imagePath.startsWith('https://');
  developer.log(
    'buildSectionImage (web) path=${imagePath.substring(0, imagePath.length.clamp(0, 80))}... isNetwork=$isNetwork',
    name: 'SectionImage',
  );

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
            developer.log(
              'CustomNetworkImage LOAD ERROR: $error',
              name: 'SectionImage',
            );
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

  // Asset path: fetch via HTTP (try multiple path variants for debug vs release)
  // then display with Image.memory. Cache by path so rebuilds don't reload.
  return FutureBuilder<typed_data.Uint8List>(
    future: _getCachedAssetBytes(imagePath),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
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
      }
      if (snapshot.hasError || !snapshot.hasData) {
        developer.log('Asset load failed: ${snapshot.error}', name: 'SectionImage');
        final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
        return errorBuilder?.call(context, snapshot.error ?? Object(), StackTrace.current) ??
            Container(
              color: theme.surfaceSecondary,
              child: Center(
                child: Icon(Icons.broken_image_outlined, color: theme.textSecondary),
              ),
            );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          // Image needs bounded constraints; parent may give unbounded height
          final hasBounded = constraints.maxWidth.isFinite && constraints.maxHeight.isFinite;
          if (hasBounded) {
            return SizedBox.expand(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
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
              ),
            );
          }
          final w = width ?? constraints.maxWidth;
          final h = height ?? constraints.maxHeight;
          final boundedH = (h.isFinite ? h : (w.isFinite ? w * 0.75 : 400.0)).toDouble();
          final boundedW = (w.isFinite ? w : (boundedH * 4 / 3)).toDouble();
          return SizedBox(
            width: boundedW,
            height: boundedH,
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
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
            ),
          );
        },
      );
    },
  );
}

final _assetBytesCache = <String, Future<typed_data.Uint8List>>{};

Future<typed_data.Uint8List> _getCachedAssetBytes(String path) {
  return _assetBytesCache.putIfAbsent(path, () => _loadAssetBytes(path));
}

/// Fetches asset bytes. Tries rootBundle first, then HTTP with path variants.
Future<typed_data.Uint8List> _loadAssetBytes(String path) async {
  // Try rootBundle first (works on some Flutter web setups)
  try {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } catch (_) {}

  // Fallback: HTTP fetch with path variants (debug vs release)
  final base = Uri.base;
  final candidates = <String>[
    'assets/$path', // assets/assets/... (release + many debug)
    path,
    if (path.startsWith('assets/')) path.substring(7),
  ];
  for (final p in candidates) {
    final uri = base.resolve(p);
    try {
      final request = await html.HttpRequest.request(
        uri.toString(),
        responseType: 'arraybuffer',
      );
      final status = request.status ?? 0;
      if (status >= 200 && status < 300) {
        final response = request.response;
        if (response != null) {
          if (response is typed_data.ByteBuffer) {
            return typed_data.Uint8List.view(response);
          }
          if (response is typed_data.Uint8List) {
            return response;
          }
        }
      }
    } catch (e) {
      developer.log('_loadAssetBytes try $p failed: $e', name: 'SectionImage');
    }
  }
  throw Exception('Failed to load asset: $path');
}
