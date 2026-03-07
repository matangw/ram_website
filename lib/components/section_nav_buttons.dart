import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ram_website/theme/theme_colors.dart';

/// Premium section navigation bar for memorial landing pages.
///
/// Fits inside [FadingHeader] nav overlay with glassmorphism styling.
/// Highlights the currently visible section and scrolls on tap.
class SectionNavButtons extends StatelessWidget {
  const SectionNavButtons({
    super.key,
    required this.currentSectionIndex,
    required this.onSectionTap,
  });

  final int currentSectionIndex;
  final ValueChanged<int> onSectionTap;

  static const List<String> _sections = ['אודות', 'שירות', 'ציטוטים', 'תרומה'];

  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _mobileBreakpoint;

    final textDirection = Directionality.of(context);
    return Wrap(
      textDirection: textDirection,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: isMobile ? 8 : 16,
      runSpacing: isMobile ? 8 : 0,
      children: List.generate(
        _sections.length,
        (index) => _NavButton(
          label: _sections[index],
          isActive: currentSectionIndex == index,
          onTap: () => onSectionTap(index),
          compact: isMobile,
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
    final isInteractive = _isHovered || _isPressed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        onHighlightChanged: (pressed) => setState(() => _isPressed = pressed),
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.black.withOpacity(0.08),
        highlightColor: Colors.black.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 18,
            vertical: widget.compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isActive
                ? Colors.black.withOpacity(0.08)
                : (isInteractive ? Colors.black.withOpacity(0.04) : null),
            border: Border.all(
              color: widget.isActive
                  ? Colors.black.withOpacity(0.2)
                  : (isInteractive ? Colors.black.withOpacity(0.1) : Colors.transparent),
              width: 1,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            style: GoogleFonts.heebo(
              fontSize: widget.compact ? 13 : 14,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.2,
              color: widget.isActive
                  ? theme.textPrimary
                  : theme.textPrimary.withOpacity(isInteractive ? 0.9 : 0.7),
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
