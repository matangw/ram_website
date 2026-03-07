import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
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

  static const double _sectionAlignment = 0.2;
  static const double _touchDragThreshold = 30;
  static const double _wheelAccumulateThreshold = 40;
  static const _scrollCooldown = Duration(milliseconds: 600);

  double? _dragStartY;
  double _wheelAccumulated = 0;
  DateTime? _lastScrollStepAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndUpdateSectionOffsets());
  }

  void _measureAndUpdateSectionOffsets() {
    if (!mounted) return;
    final viewportHeight = MediaQuery.of(context).size.height;

    final sectionGlobalTops = <double>[];
    for (final key in _sectionKeys) {
      final context = key.currentContext;
      if (context == null) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final top = box.localToGlobal(Offset.zero).dy;
      sectionGlobalTops.add(top);
    }

    if (sectionGlobalTops.length < 4) return;

    // sectionTopInContent[i] = sectionGlobalY[i] - sectionGlobalY[0] + viewportHeight
    // (Bio section starts at viewportHeight in scroll content)
    final section0TopInContent = viewportHeight;
    final sectionTopsInContent = [
      section0TopInContent,
      sectionGlobalTops[1] - sectionGlobalTops[0] + section0TopInContent,
      sectionGlobalTops[2] - sectionGlobalTops[0] + section0TopInContent,
      sectionGlobalTops[3] - sectionGlobalTops[0] + section0TopInContent,
    ];

    // Target scroll offset so section top is at alignment from viewport top
    final targets = sectionTopsInContent
        .map((top) => (top - _sectionAlignment * viewportHeight).clamp(0.0, double.infinity))
        .toList();

    _scrollCtrl.updateSectionOffsets(targets);
    _scrollCtrl.updateSnapOffsets([0.0, ...targets]);
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height;
    _scrollCtrl.viewportHeight = viewportHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndUpdateSectionOffsets());
        return Scaffold(
          backgroundColor: const Color(0xFFFAF7F2),
          body: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: (event) {
              if (event is! PointerScrollEvent) return;
              if (_lastScrollStepAt != null &&
                  DateTime.now().difference(_lastScrollStepAt!) < _scrollCooldown) {
                return;
              }
              _wheelAccumulated += event.scrollDelta.dy;
              if (_wheelAccumulated > _wheelAccumulateThreshold) {
                _scrollCtrl.goToNextSection();
                _wheelAccumulated = 0;
                _lastScrollStepAt = DateTime.now();
              } else if (_wheelAccumulated < -_wheelAccumulateThreshold) {
                _scrollCtrl.goToPreviousSection();
                _wheelAccumulated = 0;
                _lastScrollStepAt = DateTime.now();
              }
            },
            onPointerDown: (event) => _dragStartY = event.position.dy,
            onPointerMove: (_) {},
            onPointerUp: (event) {
              final startY = _dragStartY;
              _dragStartY = null;
              if (startY == null) return;
              if (_lastScrollStepAt != null &&
                  DateTime.now().difference(_lastScrollStepAt!) < _scrollCooldown) {
                return;
              }
              final delta = event.position.dy - startY;
              if (delta > _touchDragThreshold) {
                _scrollCtrl.goToNextSection();
                _lastScrollStepAt = DateTime.now();
              } else if (delta < -_touchDragThreshold) {
                _scrollCtrl.goToPreviousSection();
                _lastScrollStepAt = DateTime.now();
              }
            },
            onPointerCancel: (_) => _dragStartY = null,
            child: Stack(
              children: [
                // Scrollable body - step-based scroll (no free scroll)
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollCtrl.scrollController,
                    child: Obx(() {
                      final currentSection = _scrollCtrl.currentSection.value;
                      return Column(
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
                                isCurrentSection: currentSection == 0,
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
                                isCurrentSection: currentSection == 1,
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
                                  isCurrentSection: currentSection == 2,
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
                                isCurrentSection: currentSection == 3,
                                onPressed: () {
                                  // TODO: Open donation link
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                // Fading header overlay - drawn on top, fades on scroll
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
                            currentImageIndex: ctrl.headerImageIndex.value,
                            profileImagePath: ctrl.headerProfileImagePath.value,
                            name: ctrl.headerName.value,
                            yearFrom: ctrl.headerYearFrom,
                            yearTo: ctrl.headerYearTo,
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
          ),
        );
      },
    );
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final ctx = key.currentContext;
    if (ctx != null) {
      _scrollCtrl.setProgrammaticScroll(true);
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: _sectionAlignment,
      );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _scrollCtrl.setProgrammaticScroll(false);
      });
    }
  }
}
