import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ram_website/theme/theme_colors.dart';
import 'package:ram_website/widgets/section_image.dart';

/// A premium full-width hero section for memorial landing pages.
///
/// Features:
/// - Rotating background images with smooth crossfade (every 6 seconds)
/// - Opacity controlled by scroll offset (passed from parent)
/// - Dark theme with subtle accents
/// - Glassmorphism overlay at top for navigation
/// - Full viewport height, responsive via LayoutBuilder
class FadingHeader extends StatefulWidget {
  const FadingHeader({
    super.key,
    required this.imagePaths,
    required this.opacity,
    this.navOverlay,
    this.currentImageIndex,
    this.rotationInterval = const Duration(seconds: 6),
    this.crossfadeDuration = const Duration(milliseconds: 1500),
    this.profileImagePath,
    this.name,
    this.yearFrom = 0,
    this.yearTo = 0,
  });

  final List<String> imagePaths;
  final double opacity;
  final Widget? navOverlay;
  /// When set, uses this index instead of internal rotation (parent-controlled).
  final int? currentImageIndex;
  final Duration rotationInterval;
  final Duration crossfadeDuration;
  final String? profileImagePath;
  final String? name;
  final int yearFrom;
  final int yearTo;

  @override
  State<FadingHeader> createState() => _FadingHeaderState();
}

class _FadingHeaderState extends State<FadingHeader> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.currentImageIndex == null && widget.imagePaths.length > 1) {
      _startImageRotation();
    }
  }

  void _startImageRotation() {
    Future.doWhile(() async {
      await Future.delayed(widget.rotationInterval);
      if (!mounted) return false;
      setState(() {
        _currentImageIndex =
            (_currentImageIndex + 1) % widget.imagePaths.length;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height;
    final viewportWidth = MediaQuery.of(context).size.width;

    // Use SizedBox directly - LayoutBuilder doesn't support intrinsic dimensions
    // and we use MediaQuery for viewport size, not layout constraints
    return SizedBox(
      height: viewportHeight,
      width: viewportWidth,
      child: Opacity(
        opacity: widget.opacity.clamp(0.0, 1.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background - ignore pointer so scroll passes through
            IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: _BackgroundImageStack(
                      imagePaths: widget.imagePaths,
                      currentIndex: widget.currentImageIndex ?? _currentImageIndex,
                      crossfadeDuration: widget.crossfadeDuration,
                    ),
                  ),
                  const _DarkGradientOverlay(),
                ],
              ),
            ),
            if (_hasCenterContent)
              Positioned.fill(
                child: IgnorePointer(
                  child: _HeaderCenterContent(
                    profileImagePath: widget.profileImagePath ?? '',
                    name: widget.name ?? '',
                    yearFrom: widget.yearFrom,
                    yearTo: widget.yearTo,
                  ),
                ),
              ),
            if (widget.navOverlay != null)
              _GlassmorphismNavBar(child: widget.navOverlay!),
          ],
        ),
      ),
    );
  }

  bool get _hasCenterContent =>
      (widget.profileImagePath?.isNotEmpty ?? false) ||
      (widget.name?.isNotEmpty ?? false);
}

class _BackgroundImageStack extends StatelessWidget {
  const _BackgroundImageStack({
    required this.imagePaths,
    required this.currentIndex,
    required this.crossfadeDuration,
  });

  final List<String> imagePaths;
  final int currentIndex;
  final Duration crossfadeDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
    if (imagePaths.isEmpty) {
      return Container(
        color: theme.surface,
      );
    }

    final safeIndex = currentIndex % imagePaths.length;
    return AnimatedSwitcher(
      duration: crossfadeDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _BackgroundImage(
        key: ValueKey<int>(safeIndex),
        imagePath: imagePaths[safeIndex],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
    return SizedBox.expand(
      child: buildSectionImage(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          developer.log('IMAGE LOAD ERROR: $error', name: 'FadingHeader');
          developer.log('stackTrace: $stackTrace', name: 'FadingHeader');
          return Container(
            color: theme.surface,
            child: Center(
              child: Text(
                'הוסף תמונות ל-assets/header/',
                style: GoogleFonts.heebo(
                  color: theme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DarkGradientOverlay extends StatelessWidget {
  const _DarkGradientOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.shadowLight,
              theme.shadowMedium,
              theme.shadowDark,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class _HeaderCenterContent extends StatelessWidget {
  const _HeaderCenterContent({
    required this.profileImagePath,
    required this.name,
    required this.yearFrom,
    required this.yearTo,
  });

  final String profileImagePath;
  final String name;
  final int yearFrom;
  final int yearTo;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 900;

    final imageSize = isMobile ? 140.0 : (isTablet ? 180.0 : 220.0);
    final nameFontSize = isMobile ? 20.0 : 24.0;
    final yearFontSize = isMobile ? 16.0 : 18.0;
    final badgePaddingH = isMobile ? 16.0 : 20.0;
    final badgePaddingV = isMobile ? 8.0 : 10.0;

    return Center(
      child: Transform.translate(
        offset: const Offset(0, -24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (profileImagePath.isNotEmpty) ...[
              _ProfileImage(
                imagePath: profileImagePath,
                width: imageSize,
                height: imageSize * 1.4,
              ),
              const SizedBox(height: 20),
            ],
            if (name.isNotEmpty)
              _Badge(
                text: name,
                fontSize: nameFontSize,
                fontWeight: FontWeight.w700,
                paddingH: badgePaddingH,
                paddingV: badgePaddingV,
              ),
            if (name.isNotEmpty && (yearFrom > 0 || yearTo > 0))
              const SizedBox(height: 12),
            if (yearFrom > 0 || yearTo > 0)
              _Badge(
                text: '$yearFrom - $yearTo',
                fontSize: yearFontSize,
                fontWeight: FontWeight.w600,
                paddingH: badgePaddingH,
                paddingV: badgePaddingV,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  final String imagePath;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.surface.withOpacity(0.9),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.tertiaryGold.withOpacity(0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: theme.shadowMedium,
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: buildSectionImage(
          imagePath,
          fit: BoxFit.cover,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: theme.surfaceSecondary,
              child: Icon(
                Icons.person,
                size: width * 0.5,
                color: theme.textSecondary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.paddingH,
    required this.paddingV,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double paddingH;
  final double paddingV;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: theme.primaryGold.withOpacity(0.93),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.heebo(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: fontWeight == FontWeight.w700 ? 0.5 : 0.3,
        ),
      ),
    );
  }
}

class _GlassmorphismNavBar extends StatelessWidget {
  const _GlassmorphismNavBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MemorialThemeExtension>()!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsetsDirectional.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 16,
              start: 20,
              end: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.surface.withOpacity(0.85),
                  theme.surfaceSecondary.withOpacity(0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.shadowLight.withOpacity(0.4),
                  width: 1,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
