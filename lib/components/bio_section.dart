import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ram_website/widgets/section_image.dart';

/// A premium full-width bio section for memorial landing pages.
///
/// Features:
/// - LEFT: Bio text (elegant typography)
/// - RIGHT: Rotating profile image (parent passes current image path)
/// - Responsive: LayoutBuilder stacks vertically on mobile
/// - Dark theme (#0D0D0D), min height ~400px
/// - Entrance animation when section comes into view
///
/// Scroll-to-section: Pass a [GlobalKey] as [key] so the parent can scroll to
/// this section, e.g. `Scrollable.ensureVisible(key.currentContext!)`.
class BioSection extends StatelessWidget {
  const BioSection({
    super.key,
    required this.bioText,
    required this.imagePath,
  });

  /// Short bio text displayed on the left (desktop) or top (mobile).
  final String bioText;

  /// Current rotating image path. Parent manages rotation; can be empty.
  final String imagePath;

  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _minHeight = 400;
  static const Color _bgColor = Color(0xFF0D0D0D);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _mobileBreakpoint;
    final isTablet = width >= _mobileBreakpoint && width < _tabletBreakpoint;

    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 32.0 : 48.0);
    final verticalPadding = isMobile ? 40.0 : 64.0;
    final gap = isMobile ? 24.0 : 40.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: _minHeight),
      color: _bgColor,
      padding: EdgeInsetsDirectional.only(
        start: horizontalPadding,
        end: horizontalPadding,
        top: verticalPadding,
        bottom: verticalPadding,
      ),
      child: isMobile
          ? _buildMobileLayout(context, gap)
          : _buildDesktopLayout(context, gap, isTablet),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double gap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BioContent(bioText: bioText),
        SizedBox(height: gap),
        _ProfileImage(imagePath: imagePath),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    double gap,
    bool isTablet,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : 1000,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                flex: isTablet ? 5 : 6,
                child: _BioContent(bioText: bioText),
              ),
              SizedBox(width: gap),
              Expanded(
                flex: isTablet ? 4 : 5,
                child: _ProfileImage(imagePath: imagePath),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BioContent extends StatelessWidget {
  const _BioContent({required this.bioText});

  final String bioText;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: isMobile ? 0 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            bioText,
            textAlign: TextAlign.start,
            style: GoogleFonts.heebo(
              fontSize: isMobile ? 18 : 22,
              height: 1.7,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.92),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final aspectRatio = isMobile ? 4 / 3 : 3 / 4;
    final maxHeight = isMobile ? 280.0 : 360.0;

    if (imagePath.isEmpty) {
      developer.log('_ProfileImage: imagePath is EMPTY', name: 'BioSection');
      return _PlaceholderImage(
        aspectRatio: aspectRatio,
        maxHeight: maxHeight,
        isMobile: isMobile,
      );
    }
    developer.log('_ProfileImage: loading url=${imagePath.substring(0, imagePath.length.clamp(0, 60))}...', name: 'BioSection');

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: isMobile ? 200 : 280,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey<String>(imagePath),
            child: _buildImage(imagePath, aspectRatio, maxHeight, isMobile),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path, double aspectRatio, double maxHeight, bool isMobile) {
    final placeholder = _PlaceholderImage(
      aspectRatio: aspectRatio,
      maxHeight: maxHeight,
      isMobile: isMobile,
    );
    return buildSectionImage(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, error, st) {
        developer.log('IMAGE LOAD ERROR: $error', name: 'BioSection');
        developer.log('stackTrace: $st', name: 'BioSection');
        return placeholder;
      },
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({
    required this.aspectRatio,
    required this.maxHeight,
    required this.isMobile,
  });

  final double aspectRatio;
  final double maxHeight;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: isMobile ? 200 : 280,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Center(
          child: Icon(
            Icons.person_outline_rounded,
            size: 40,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}
