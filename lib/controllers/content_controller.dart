import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:get/get.dart';

import '../services/asset_loader.dart';
import '../services/section_image_loader.dart';

/// Manages rotating content: header images, bio images, army images, quotes.
class ContentController extends GetxController {
  /// Rotation interval in seconds (staggered: one section changes per tick)
  static const int rotationIntervalSeconds = 7;

  Timer? _rotationTimer;
  int _rotationCycleIndex = 0; // 0=header, 1=bio, 2=army, 3=quotes

  // Header images
  final headerImageIndex = 0.obs;
  List<String> headerImagePaths = [];

  // Bio images
  final bioImageIndex = 0.obs;
  List<String> bioImagePaths = [];

  // Army images
  final armyImageIndex = 0.obs;
  List<String> armyImagePaths = [];

  // Quotes
  final quoteIndex = 0.obs;
  List<Map<String, String>> quotes = [];

  // Bio text (reactive for initial load)
  final bioText = ''.obs;

  // Army service summary
  final armySummary = ''.obs;

  // Donation content
  final donationTitle = ''.obs;
  final donationBody = ''.obs;
  final donationCtaText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAssets();
    _startRotationTimer();
  }

  Future<void> _loadAssets() async {
    developer.log('_loadAssets started', name: 'ContentController');
    await Future.wait([
      _loadHeaderImages(),
      _loadBioContent(),
      _loadArmyContent(),
      _loadQuotes(),
      _loadDonationContent(),
    ]);
    developer.log('_loadAssets done. header=${headerImagePaths.length} bio=${bioImagePaths.length} army=${armyImagePaths.length}', name: 'ContentController');
    update();
  }

  Future<void> _loadHeaderImages() async {
    try {
      headerImagePaths = await loadSectionImages('assets/header/images/');
      developer.log('header images loaded: ${headerImagePaths.length} paths. First: ${headerImagePaths.isNotEmpty ? headerImagePaths.first.substring(0, headerImagePaths.first.length.clamp(0, 60)) : "none"}...', name: 'ContentController');
    } catch (e, st) {
      developer.log('header load FAILED: $e', name: 'ContentController');
      developer.log('stack: $st', name: 'ContentController');
      headerImagePaths = [];
    }
  }

  Future<void> _loadBioContent() async {
    try {
      final jsonStr = await loadAssetString('assets/bio/bio.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      bioText.value = data['text'] as String? ?? '';
      bioImagePaths = await loadSectionImages('assets/bio/images/');
      developer.log('bio images loaded: ${bioImagePaths.length} paths', name: 'ContentController');
    } catch (e, st) {
      developer.log('bio load FAILED: $e', name: 'ContentController');
      developer.log('stack: $st', name: 'ContentController');
      bioText.value = 'הוסף ביוגרפיה ב-assets/bio/bio.json';
      bioImagePaths = [];
    }
  }

  Future<void> _loadArmyContent() async {
    try {
      final jsonStr = await loadAssetString('assets/army/service.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      armySummary.value = data['summary'] as String? ?? '';
      armyImagePaths = await loadSectionImages('assets/army/images/');
      developer.log('army images loaded: ${armyImagePaths.length} paths', name: 'ContentController');
    } catch (e, st) {
      developer.log('army load FAILED: $e', name: 'ContentController');
      developer.log('stack: $st', name: 'ContentController');
      armySummary.value = 'הוסף סיכום שירות צבאי ב-assets/army/service.json';
      armyImagePaths = [];
    }
  }

  Future<void> _loadQuotes() async {
    try {
      final jsonStr = await loadAssetString('assets/quotes/quotes.json');
      final data = json.decode(jsonStr);
      if (data is List) {
        quotes = data
            .map((e) => {
                  'author': (e as Map)['author']?.toString() ?? '',
                  'quote': (e)['quote']?.toString() ?? '',
                })
            .toList();
      }
      if (quotes.isEmpty) {
        quotes = [
          {'author': 'חבר', 'quote': 'הוסף ציטוטים ב-assets/quotes/quotes.json'},
        ];
      }
    } catch (_) {
      quotes = [
        {'author': 'חבר', 'quote': 'הוסף ציטוטים ב-assets/quotes/quotes.json'},
      ];
    }
  }

  Future<void> _loadDonationContent() async {
    try {
      final jsonStr = await loadAssetString('assets/donation/donation.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      donationTitle.value = data['title'] as String? ?? 'תמכו באנדרטה';
      donationBody.value = data['body'] as String? ?? '';
      donationCtaText.value = data['ctaText'] as String? ?? 'לתרומה עכשיו';
    } catch (_) {
      donationTitle.value = 'תמכו באנדרטה';
      donationBody.value = 'התרומה שלך תכבד את זכרו.';
      donationCtaText.value = 'לתרומה עכשיו';
    }
  }

  void _startRotationTimer() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(
      const Duration(seconds: rotationIntervalSeconds),
      (_) => _rotateNext(),
    );
  }

  void _rotateNext() {
    switch (_rotationCycleIndex) {
      case 0:
        if (headerImagePaths.isNotEmpty) {
          headerImageIndex.value =
              (headerImageIndex.value + 1) % headerImagePaths.length;
        }
        break;
      case 1:
        if (bioImagePaths.isNotEmpty) {
          bioImageIndex.value =
              (bioImageIndex.value + 1) % bioImagePaths.length;
        }
        break;
      case 2:
        if (armyImagePaths.isNotEmpty) {
          armyImageIndex.value =
              (armyImageIndex.value + 1) % armyImagePaths.length;
        }
        break;
      case 3:
        if (quotes.isNotEmpty) {
          quoteIndex.value = (quoteIndex.value + 1) % quotes.length;
        }
        break;
    }
    _rotationCycleIndex = (_rotationCycleIndex + 1) % 4;
    update();
  }

  String get currentHeaderImage =>
      headerImagePaths.isNotEmpty
          ? headerImagePaths[headerImageIndex.value % headerImagePaths.length]
          : '';

  String get currentBioImage =>
      bioImagePaths.isNotEmpty
          ? bioImagePaths[bioImageIndex.value % bioImagePaths.length]
          : '';

  String get currentArmyImage =>
      armyImagePaths.isNotEmpty
          ? armyImagePaths[armyImageIndex.value % armyImagePaths.length]
          : '';

  Map<String, String> get currentQuote =>
      quotes.isNotEmpty
          ? quotes[quoteIndex.value % quotes.length]
          : {'author': '', 'quote': ''};

  @override
  void onClose() {
    _rotationTimer?.cancel();
    super.onClose();
  }
}
