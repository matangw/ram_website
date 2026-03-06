import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ram_website/widgets/section_image.dart';

/// A premium full-width section for memorial landing pages showcasing
/// Army service with summary text and rotating images.
///
/// Features:
/// - Left: Army service summary text
/// - Right: Image (parent passes currentImagePath for rotation control)
/// - LayoutBuilder: Desktop = side-by-side; Mobile = stacked (summary top, image below)
/// - Dark theme with tasteful military-inspired accents (muted green/gold)
/// - Flat image with accent border
/// - Entrance animation via flutter_animate
class ArmySection extends StatelessWidget {
  const ArmySection({
    super.key,
    required this.serviceSummary,
    required this.imagePath,
    this.minHeight = 400,
  });

  /// The Army service summary text displayed on the left (or top on mobile).
  final String serviceSummary;

  /// Current image path for the rotating image. Can be empty to hide the image.
  final String imagePath;

  /// Minimum height of the section in logical pixels.
  final double minHeight;

  // Optimistic memorial accents (sage, warm bronze)
  static const Color _accentGreen = Color(0xFF7A9B76);
  static const Color _accentGreenDark = Color(0xFF5A7856); // darker variant for borders
  static const Color _accentGold = Color(0xFF8B7355);
  static const Color _bgDark = Color(0xFFFAF7F2);
  static const Color _cardBg = Color(0xFFF5F0E8);
  static const Color _textPrimary = Color(0xFF2D2D2D);
  static const Color _textSecondary = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            color: _bgDark,
            border: Border(
              top: BorderSide(color: _accentGreen.withOpacity(0.3), width: 1),
              bottom: BorderSide(color: _accentGold.withOpacity(0.2), width: 1),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: isMobile ? 20 : 48,
              end: isMobile ? 20 : 48,
              top: isMobile ? 32 : 48,
              bottom: isMobile ? 32 : 48,
            ),
            child: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
          ),
        );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                flex: 1,
                child: _buildSummaryContent(),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 2,
                child: _buildImageContent(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSummaryContent(),
        const SizedBox(height: 32),
        _buildImageContent(context),
      ],
    );
  }

  Widget _buildSummaryContent() {
    return _AnimatedContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                height: 3,
                width: 48,
                decoration: BoxDecoration(
                  color: _accentGold.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'שירות',
                style: GoogleFonts.heebo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3,
                  color: _accentGold.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            serviceSummary,
            textAlign: TextAlign.start,
            style: GoogleFonts.heebo(
              fontSize: 16,
              height: 1.7,
              color: _textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    // Use 4/3 (landscape) on desktop so image fills width like bio section
    final aspectRatio = 4 / 3;
    final maxHeight = isMobile ? 260.0 : 340.0;

    if (imagePath.isEmpty) {
      developer.log('imagePath is EMPTY', name: 'ArmySection');
      return _AnimatedContent(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: 160,
          ),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _accentGreenDark,
              width: 6,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: _textSecondary.withOpacity(0.4),
            ),
          ),
        ),
      );
    }

    developer.log('loading url=${imagePath.substring(0, imagePath.length.clamp(0, 60))}...', name: 'ArmySection');

    final errorPlaceholder = Container(
      color: _cardBg,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: _textSecondary.withOpacity(0.4),
        ),
      ),
    );

    return _AnimatedContent(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minHeight: 160,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _accentGreenDark,
            width: 6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: KeyedSubtree(
                key: ValueKey<String>(imagePath),
                child: buildSectionImage(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, error, st) {
                    developer.log('IMAGE LOAD ERROR: $error', name: 'ArmySection');
                    developer.log('stackTrace: $st', name: 'ArmySection');
                    return errorPlaceholder;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedContent extends StatelessWidget {
  const _AnimatedContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
