import 'package:flutter/material.dart';

/// Wraps section text content with slide-in-from-top animation.
/// Content is visible only when [isCurrentSection] is true; otherwise hidden.
class AnimatedSectionContent extends StatelessWidget {
  const AnimatedSectionContent({
    super.key,
    required this.isCurrentSection,
    required this.child,
  });

  final bool isCurrentSection;
  final Widget child;

  static const _duration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: isCurrentSection
          ? KeyedSubtree(key: const ValueKey('visible'), child: child)
          : SizedBox.shrink(key: const ValueKey('hidden')),
    );
  }
}
