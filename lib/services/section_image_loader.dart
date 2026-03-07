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

/// Looks for a profile image in the header folder.
/// Returns the first matching path (profile_image.png or profile.png), or empty string if none found.
Future<String> loadHeaderProfileImagePath() async {
  try {
    final headerAssets = await loadSectionImages('assets/header/');
    final profileNames = ['profile_image.png', 'profile.png'];
    for (final name in profileNames) {
      final match = headerAssets
          .where((p) => p.toLowerCase().endsWith(name))
          .toList();
      if (match.isNotEmpty) return match.first;
    }
    return '';
  } catch (_) {
    return '';
  }
}
