import 'dart:html' as html;

/// Loads asset strings on web via fetch.
/// Bypasses Flutter's rootBundle which has assets/assets/ path bug.
Future<String> loadAssetString(String path) async {
  // path is like "assets/header/header.json"
  // Try multiple path variants: Flutter web has inconsistent asset paths
  // (single assets/, double assets/assets/, and base-href subpaths)
  final base = Uri.base;
  final candidates = <String>[
    path,
    'assets/$path',
    if (path.startsWith('assets/')) path.substring(7), // "header/header.json"
  ];
  for (final p in candidates) {
    final uri = base.resolve(p);
    try {
      final response = await html.HttpRequest.request(
        uri.toString(),
        requestHeaders: {'Accept': 'application/json'},
      );
      final status = response.status ?? 0;
      if (status >= 200 && status < 300) {
        final text = response.responseText ?? '';
        if (text.trim().startsWith('{') || text.trim().startsWith('[')) {
          return text;
        }
        // Avoid returning HTML (e.g. 404 page) as JSON
      }
    } catch (_) {}
  }
  throw Exception('Failed to load $path');
}
