import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/home_page.dart';
import 'theme/theme_colors.dart';

void main() {
  developer.log('=== RAM_WEBSITE APP START ===', name: 'RAM_IMAGES');
  runApp(const MemorialApp());
}

class MemorialApp extends StatelessWidget {
  const MemorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = MemorialThemeExtension.light;
    return GetMaterialApp(
      title: 'Memorial',
      debugShowCheckedModeBanner: false,
      locale: const Locale('he', 'IL'),
      fallbackLocale: const Locale('he', 'IL'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: ext.primaryGold,
          surface: ext.surface,
          onSurface: ext.textPrimary,
          onSurfaceVariant: ext.textSecondary,
          tertiary: ext.tertiaryGold,
        ),
        extensions: [ext],
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomePage(),
    );
  }
}
