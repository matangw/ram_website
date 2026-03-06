import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium full-width donation section for memorial landing pages.
///
/// Features:
/// - Displays donation title, body text, and a prominent CTA button
/// - Dark theme (#0D0D0D), full-width section
/// - CTA with hover/pressed micro-interactions (InkWell, AnimatedContainer)
/// - Entrance animation via flutter_animate
/// - Responsive padding
///
/// Style: Dark background, white/grey text, gold accent CTA — tasteful and
/// supportive, inviting without being pushy.
class DonationSection extends StatelessWidget {
  const DonationSection({
    super.key,
    required this.title,
    required this.body,
    required this.ctaText,
    this.onPressed,
  });

  /// Section title (e.g. "Support the Memorial").
  final String title;

  /// Body text explaining the need for donations.
  final String body;

  /// CTA button label (e.g. "Donate Now").
  final String ctaText;

  /// Callback when CTA is pressed. Use empty/placeholder if not yet wired.
  final VoidCallback? onPressed;

  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const Color _bgColor = Color(0xFF0D0D0D);
  static const Color _accentColor = Color(0xFFC9A227); // Warm gold, memorial-appropriate

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _mobileBreakpoint;
    final isTablet = width >= _mobileBreakpoint && width < _tabletBreakpoint;

    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 32.0 : 48.0);
    final verticalPadding = isMobile ? 48.0 : 72.0;
    final maxContentWidth = isTablet ? 640.0 : 560.0;

    return Container(
          width: double.infinity,
          color: _bgColor,
          padding: EdgeInsetsDirectional.only(
            start: horizontalPadding,
            end: horizontalPadding,
            top: verticalPadding,
            bottom: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.heebo(
                      fontSize: isMobile ? 28 : 34,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  Text(
                    body,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.heebo(
                      fontSize: isMobile ? 15 : 17,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.78),
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: isMobile ? 28 : 36),
                  _DonationCta(
                    label: ctaText,
                    accentColor: _accentColor,
                    onPressed: onPressed ?? () {},
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

/// CTA button with hover and pressed micro-interactions.
class _DonationCta extends StatefulWidget {
  const _DonationCta({
    required this.label,
    required this.accentColor,
    required this.onPressed,
  });

  final String label;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  State<_DonationCta> createState() => _DonationCtaState();
}

class _DonationCtaState extends State<_DonationCta> {
  bool _isHovered = false;
  bool _isPressed = false;

  Color _computeBackgroundColor() {
    if (_isPressed) {
      return Color.lerp(
        widget.accentColor,
        const Color(0xFF1A1A1A),
        0.12,
      ) ?? widget.accentColor;
    }
    if (_isHovered) {
      return Color.lerp(
        widget.accentColor,
        Colors.white,
        0.1,
      ) ?? widget.accentColor;
    }
    return widget.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0);
    final shadowBlur = _isHovered ? 20.0 : 12.0;
    final shadowOpacity = _isHovered ? 0.35 : 0.25;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(scale),
          transformAlignment: Alignment.center,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: _computeBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(shadowOpacity),
                blurRadius: shadowBlur,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  widget.label,
                  style: GoogleFonts.heebo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
