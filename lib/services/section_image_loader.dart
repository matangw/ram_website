import 'dart:developer' as developer;

import 'package:flutter/services.dart';

const _imageExtensions = {'.png', '.jpg', '.jpeg', '.webp', '.gif'};

/// Loads image asset paths for a section by discovering files in the given
/// folder via the AssetManifest. No JSON needed—just add images to the folder.
Future<List<String>> loadSectionImages(String prefix) async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final all = manifest.listAssets();
    developer.log('loadSectionImages: prefix=$prefix, total assets=${all.length}', name: 'SectionImageLoader');
    final filtered = all
        .where((key) =>
            key.startsWith(prefix) &&
            _imageExtensions.any((ext) => key.toLowerCase().endsWith(ext)))
        .toList()
      ..sort();
    developer.log('loadSectionImages: found ${filtered.length} images for $prefix', name: 'SectionImageLoader');
    return filtered;
  } catch (e, st) {
    developer.log('loadSectionImages FAILED: $e\n$st', name: 'SectionImageLoader');
    return [];
  }
}
