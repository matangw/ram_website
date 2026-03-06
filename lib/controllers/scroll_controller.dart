import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Manages scroll state for the memorial landing page.
/// Tracks scroll offset for header opacity and section navigation.
class LandingScrollController extends GetxController {
  final ScrollController scrollController = ScrollController();

  /// Scroll offset - used for header fade
  final scrollOffset = 0.0.obs;

  /// Threshold in pixels after which header is fully faded
  static const double fadeThreshold = 400.0;

  /// Current section index (0 = bio, 1 = army, 2 = quotes, 3 = donation)
  final currentSection = 0.obs;

  /// Section start offsets (scroll offset at which each section begins)
  final List<double> sectionOffsets = [0, 0, 0, 0];

  /// Viewport height - set by HomePage for section boundary calculation
  double viewportHeight = 600;

  /// Estimated section heights when offsets not yet measured
  static const List<double> _estimatedHeights = [450, 450, 300, 300];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    scrollOffset.value = scrollController.offset;
    _updateCurrentSection();
  }

  void _updateCurrentSection() {
    final offset = scrollController.offset;
    if (offset < viewportHeight - 50) {
      if (currentSection.value != 0) currentSection.value = 0;
      return;
    }
    final contentOffset = offset - viewportHeight;
    double accumulated = 0;
    int section = 0;
    for (int i = 0; i < 4; i++) {
      final sectionStart =
          sectionOffsets[i] > 0 ? sectionOffsets[i] - viewportHeight : accumulated;
      if (contentOffset >= sectionStart - 80) {
        section = i;
      }
      accumulated += sectionOffsets[i] > 0
          ? 0
          : (i < _estimatedHeights.length ? _estimatedHeights[i] : 300);
    }
    if (currentSection.value != section) {
      currentSection.value = section;
    }
  }

  /// Header opacity: 1 when at top, 0 when scrolled past fadeThreshold
  double get headerOpacity {
    final offset = scrollOffset.value;
    if (offset <= 0) return 1.0;
    if (offset >= fadeThreshold) return 0.0;
    return 1.0 - (offset / fadeThreshold);
  }

  /// Scroll to section by index
  Future<void> scrollToSection(int index) async {
    if (index < 0 || index >= sectionOffsets.length) return;
    final targetOffset = sectionOffsets[index];
    await scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  /// Update section offsets (call from HomePage after layout)
  void updateSectionOffsets(List<double> offsets) {
    for (int i = 0; i < offsets.length && i < sectionOffsets.length; i++) {
      sectionOffsets[i] = offsets[i];
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
