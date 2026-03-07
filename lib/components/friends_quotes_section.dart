import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ram_website/widgets/animated_section_content.dart';

/// A premium full-width section displaying rotating friend quotes.
///
/// Features:
/// - Centered quote with author below
/// - AnimatedSwitcher for smooth transition when quote changes
/// - Dark theme (#0D0D0D)
/// - Serif for quote, sans for author
/// - Entrance animation via flutter_animate
class FriendsQuotesSection extends StatelessWidget {
  const FriendsQuotesSection({
    super.key,
    required this.quote,
    required this.author,
    this.isCurrentSection = true,
  });

  final String quote;
  final String author;

  /// When true, quote content slides in from top; when false, content is hidden.
  final bool isCurrentSection;

  static const double _mobileBreakpoint = 600;
  static const Color _bgColor = Color(0xFFFAF7F2);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;
    final horizontalPadding = isMobile ? 24.0 : 48.0;
    final verticalPadding = isMobile ? 48.0 : 72.0;
    final quoteFontSize = isMobile ? 22.0 : 30.0;
    final authorFontSize = isMobile ? 14.0 : 16.0;

    return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 400),
          color: _bgColor,
          padding: EdgeInsetsDirectional.only(
            start: horizontalPadding,
            end: horizontalPadding,
            top: verticalPadding,
            bottom: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AnimatedSectionContent(
                isCurrentSection: isCurrentSection,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Column(
                    key: ValueKey<String>('$quote-$author'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '״',
                        style: GoogleFonts.heebo(
                          fontSize: 64,
                          height: 0.8,
                          color: Colors.black.withOpacity(0.15),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        quote,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.heebo(
                          fontSize: quoteFontSize,
                          height: 1.65,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF2D2D2D),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        author.isEmpty ? '' : '— $author',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.heebo(
                          fontSize: authorFontSize,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B6B6B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
