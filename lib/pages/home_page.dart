import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/army_section.dart';
import '../components/bio_section.dart';
import '../components/donation_section.dart';
import '../components/fading_header.dart';
import '../components/friends_quotes_section.dart';
import '../components/section_nav_buttons.dart';
import '../controllers/content_controller.dart';
import '../controllers/scroll_controller.dart' as landing;

/// Memorial landing page - composes all sections.
/// Easy to extend: add new section widget and append to list.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final landing.LandingScrollController _scrollCtrl =
      Get.put(landing.LandingScrollController());
  final ContentController _contentCtrl = Get.put(ContentController());

  final List<GlobalKey> _sectionKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height;
    _scrollCtrl.viewportHeight = viewportHeight;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Scrollable body - drawn first (bottom layer)
          SingleChildScrollView(
            controller: _scrollCtrl.scrollController,
            child: Column(
              children: [
                // Spacer so content starts below the header
                SizedBox(height: viewportHeight),

                // Section 1: Bio
                RepaintBoundary(
                  key: _sectionKeys[0],
                  child: GetBuilder<ContentController>(
                    builder: (ctrl) => BioSection(
                      bioText: ctrl.bioText.value,
                      imagePath: ctrl.currentBioImage,
                    ),
                  ),
                ),

                // Section 2: Army
                RepaintBoundary(
                  key: _sectionKeys[1],
                  child: GetBuilder<ContentController>(
                    builder: (ctrl) => ArmySection(
                      serviceSummary: ctrl.armySummary.value,
                      imagePath: ctrl.currentArmyImage,
                    ),
                  ),
                ),

                // Section 3: Friends Quotes
                RepaintBoundary(
                  key: _sectionKeys[2],
                  child: GetBuilder<ContentController>(
                    builder: (ctrl) {
                      final q = ctrl.currentQuote;
                      return FriendsQuotesSection(
                        quote: q['quote'] ?? '',
                        author: q['author'] ?? '',
                      );
                    },
                  ),
                ),

                // Section 4: Donation
                RepaintBoundary(
                  key: _sectionKeys[3],
                  child: GetBuilder<ContentController>(
                    builder: (ctrl) => DonationSection(
                      title: ctrl.donationTitle.value,
                      body: ctrl.donationBody.value,
                      ctaText: ctrl.donationCtaText.value,
                      onPressed: () {
                        // TODO: Open donation link
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fading header overlay - drawn on top, fades on scroll
          // GetBuilder ensures rebuild when images load; ListenableBuilder for scroll
          ListenableBuilder(
            listenable: _scrollCtrl.scrollController,
            builder: (context, _) {
              return GetBuilder<ContentController>(
                builder: (ctrl) {
                  developer.log('FadingHeader rebuild: headerPaths=${ctrl.headerImagePaths.length}', name: 'HomePage');
                  final offset = _scrollCtrl.scrollController.offset;
                  final sectionIndex = _scrollCtrl.currentSection.value;
                  final opacity = offset <= 0
                      ? 1.0
                      : (offset >= landing.LandingScrollController.fadeThreshold
                          ? 0.0
                          : 1.0 - (offset / landing.LandingScrollController.fadeThreshold));
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: viewportHeight,
                    child: FadingHeader(
                      imagePaths: ctrl.headerImagePaths,
                      opacity: opacity,
                      navOverlay: SectionNavButtons(
                        currentSectionIndex: sectionIndex,
                        onSectionTap: _scrollToSection,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }
}
