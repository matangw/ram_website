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

  /// Current section index (-1 = header, 0 = bio, 1 = army, 2 = quotes, 3 = donation)
  final currentSection = (-1).obs;

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

  /// Call before programmatic scroll (e.g. nav button tap).
  void setProgrammaticScroll(bool value) {
    _programmaticScroll = value;
  }

  bool _isAnimating = false;
  DateTime? _lastStepTime;
  static const _stepDuration = Duration(milliseconds: 400);
  static const _cooldownAfterStep = Duration(milliseconds: 500);

  /// Step index 0 = header, 1 = bio, 2 = army, 3 = quotes, 4 = donation.
  int _currentStepIndex() {
    if (!scrollController.hasClients || snapOffsets.isEmpty) return 0;
    final current = scrollController.offset;
    int nearest = 0;
    double minDist = (current - snapOffsets[0]).abs();
    for (int i = 1; i < snapOffsets.length; i++) {
      final d = (current - snapOffsets[i]).abs();
      if (d < minDist) {
        minDist = d;
        nearest = i;
      }
    }
    return nearest;
  }

  /// Scroll down -> next section. One step per call.
  void goToNextSection() {
    if (_isAnimating || _programmaticScroll || snapOffsets.isEmpty) return;
    if (_lastStepTime != null &&
        DateTime.now().difference(_lastStepTime!) < _cooldownAfterStep) return;
    final stepIndex = _currentStepIndex();
    if (stepIndex >= snapOffsets.length - 1) return;
    final targetIndex = stepIndex + 1;
    _animateToStep(targetIndex);
  }

  /// Scroll up -> previous section. One step per call.
  void goToPreviousSection() {
    if (_isAnimating || _programmaticScroll || snapOffsets.isEmpty) return;
    if (_lastStepTime != null &&
        DateTime.now().difference(_lastStepTime!) < _cooldownAfterStep) return;
    final stepIndex = _currentStepIndex();
    if (stepIndex <= 0) return;
    final targetIndex = stepIndex - 1;
    _animateToStep(targetIndex);
  }

  void _animateToStep(int stepIndex) {
    if (!scrollController.hasClients || stepIndex < 0 || stepIndex >= snapOffsets.length) return;
    final targetOffset = snapOffsets[stepIndex]
        .clamp(scrollController.position.minScrollExtent, scrollController.position.maxScrollExtent);
    _isAnimating = true;
    _lastStepTime = DateTime.now();
    scrollController.animateTo(
      targetOffset,
      duration: _stepDuration,
      curve: Curves.easeOut,
    ).whenComplete(() {
      _isAnimating = false;
    });
  }

  void _onScroll() {
    scrollOffset.value = scrollController.offset;
    _updateCurrentSection();
  }

  void _updateCurrentSection() {
    final stepIndex = _currentStepIndex();
    if (stepIndex == 0) {
      if (currentSection.value != -1) currentSection.value = -1;
      return;
    }
    // stepIndex 1..4 maps to section 0..3
    final section = stepIndex - 1;
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

  /// Snap offsets: [0] = header, [1..4] = section tops at alignment 0.2
  List<double> snapOffsets = [0.0];

  /// Update snap offsets (call from HomePage after layout)
  void updateSnapOffsets(List<double> offsets) {
    snapOffsets = List<double>.from(offsets);
  }

  bool _programmaticScroll = false;

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
