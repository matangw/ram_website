import 'package:flutter/material.dart';

import 'section_image_stub.dart'
    if (dart.library.html) 'section_image_stub_web.dart' as impl;

/// Displays an image from either a local asset path or a network URL.
/// Network URLs use CachedNetworkImage with HtmlImage render method on web
/// to bypass CORS; images are cached on all platforms.
Widget buildSectionImage(
  String imagePath, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return impl.buildSectionImage(
    imagePath: imagePath,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );
}
