import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    this.rotationInterval = const Duration(seconds: 6),
    this.crossfadeDuration = const Duration(milliseconds: 1500),
  });

  final List<String> imagePaths;
  final double opacity;
  final Widget? navOverlay;
  final Duration rotationInterval;
  final Duration crossfadeDuration;

  @override
  State<FadingHeader> createState() => _FadingHeaderState();
}

class _FadingHeaderState extends State<FadingHeader> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.imagePaths.length > 1) {
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
                      currentIndex: _currentImageIndex,
                      crossfadeDuration: widget.crossfadeDuration,
                    ),
                  ),
                  const _DarkGradientOverlay(),
                ],
              ),
            ),
            if (widget.navOverlay != null)
              _GlassmorphismNavBar(child: widget.navOverlay!),
          ],
        ),
      ),
    );
  }
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
    if (imagePaths.isEmpty) {
      return Container(
        color: const Color(0xFF0D0D0D),
      );
    }

    return AnimatedSwitcher(
      duration: crossfadeDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _BackgroundImage(
        key: ValueKey<int>(currentIndex),
        imagePath: imagePaths[currentIndex],
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
    return SizedBox.expand(
      child: buildSectionImage(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          developer.log('IMAGE LOAD ERROR: $error', name: 'FadingHeader');
          developer.log('stackTrace: $stackTrace', name: 'FadingHeader');
          return Container(
            color: const Color(0xFF0D0D0D),
            child: Center(
              child: Text(
                'הוסף תמונות ל-assets/header/',
                style: GoogleFonts.heebo(
                  color: Colors.white54,
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
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
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
                  const Color(0xFF1A1A1A).withOpacity(0.85),
                  const Color(0xFF0D0D0D).withOpacity(0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.08),
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
