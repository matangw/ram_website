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
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFC9A227),
          surface: const Color(0xFF0D0D0D),
          onSurface: Colors.white,
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
