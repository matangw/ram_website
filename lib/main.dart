import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/home_page.dart';

void main() {
  developer.log('=== RAM_WEBSITE APP START ===', name: 'RAM_IMAGES');
  runApp(const MemorialApp());
}

class MemorialApp extends StatelessWidget {
  const MemorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Memorial',
      debugShowCheckedModeBanner: false,
      locale: const Locale('he', 'IL'),
      fallbackLocale: const Locale('he', 'IL'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFB8860B),
          surface: const Color(0xFFFAF7F2),
          onSurface: const Color(0xFF2D2D2D),
          onSurfaceVariant: const Color(0xFF6B6B6B),
          tertiary: const Color(0xFF7A9B76),
        ),
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
