import 'package:flutter/services.dart';

/// Loads asset strings. Non-web: uses rootBundle.
Future<String> loadAssetString(String path) async {
  return rootBundle.loadString(path);
}
