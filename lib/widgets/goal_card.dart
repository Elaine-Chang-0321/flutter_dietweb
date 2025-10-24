import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalCard extends StatefulWidget {
  final int index;
  final String title;
  final int current;
  final int goal;
  final Color? backgroundColor; // Make background color optional

  const GoalCard({
    Key? key,
    required this.index,
    required this.title,
    required this.current,
    required this.goal,
    this.backgroundColor, // Make background color optional
  }) : super(key: key);

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Define background colors based on title
    Color cardBackgroundColor;
    Color textColor;
    Color progressBackgroundColor;

    switch (widget.title) {
      case 'Whole Grains':
        cardBackgroundColor = const Color(0xFFF5E8CF); // 里昂米白
        textColor = Colors.black87; // Dark text for light background
        progressBackgroundColor = const Color(0xFF16A34A); // Green
        break;
      case 'Protein':
        cardBackgroundColor = const Color(0xFFEFC3BD); // 貴婦粉紅
        textColor = Colors.black87; // Dark text for light background
        progressBackgroundColor = const Color(0xFF16A34A); // Green
        break;
      case 'Vegetables':
        cardBackgroundColor = const Color(0xFFEEE2D3); // 新的背景色
        textColor = const Color(0xFF000000); // 純黑色
        progressBackgroundColor = const Color(0xFF16A34A); // Green
        break;
      case 'Junk Food':
        cardBackgroundColor = const Color(0xFFDED3D6); // 高貴黏土
        textColor = Colors.black87; // Dark text for light background
        progressBackgroundColor = const Color(0xFFEF4444); // Red
        break;
      default:
        cardBackgroundColor = widget.backgroundColor ?? const Color(0xFFE0E0E0); // Fallback to a default grey if not matched and original is null
        textColor = const Color(0xFF111827);
        progressBackgroundColor = const Color(0xFF16A34A);
    }

    // Calculate progress
    double progress;
    Color progressBarColor = progressBackgroundColor; // Default green or red for junk food

    if (widget.title == 'Junk Food') {
      if (widget.current == 0) {
        progress = 1.0;
        progressBarColor = const Color(0xFF16A34A); // Green
      } else {
        progress = (widget.current > 0) ? 0.0 : 1.0; // If current > 0, progress is 0 for visual warning
        progressBarColor = const Color(0xFFEF4444); // Red
      }
    } else {
      progress = (widget.goal == 0) ? 0.0 : (widget.current / widget.goal).clamp(0.0, 1.0);
    }

    // Determine if "reduce intake" text should be shown
    bool showReduceIntake = widget.title == 'Junk Food' && widget.current > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovering ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: cardBackgroundColor, // Apply the determined background color
          borderRadius: BorderRadius.circular(16), // 16-20px
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovering ? 0.15 : 0.10), // Shadow deepens on hover
              offset: const Offset(0, 10),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        constraints: const BoxConstraints(
          minWidth: 240,
          minHeight: 220,
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.fredoka(
                fontSize: 28, // 18-20
                fontWeight: FontWeight.w700,
                color: textColor, // Apply the determined text color
                height: 1.3,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: '${widget.current}',
                style: GoogleFonts.fredoka(
                  fontSize: 28, // Adjusted to match title font size
                  color: textColor, // Adjusted to match title color
                  height: 1.3, // Adjusted for better vertical alignment
                  fontWeight: FontWeight.bold, // Set to bold
                ),
                children: [
                  TextSpan(
                    text: ' / ${widget.goal}',
                    style: GoogleFonts.fredoka(
                      fontSize: 28, // Adjusted to match title font size
                      color: textColor, // Adjusted to match title color
                      height: 1.3, // Adjusted for better vertical alignment
                      fontWeight: FontWeight.bold, // Set to bold
                    ),
                  ),
                  if (showReduceIntake)
                    TextSpan(
                      text: ' (reduce intake)',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        color: textColor.withOpacity(0.9), // Adjust color for warning text
                      ),
                    ),
                ],
              ),
              textAlign: TextAlign.center, // Centered alignment
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.black.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                      strokeWidth: 16.0, // Increased strokeWidth for larger indicator
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.fredoka(
                          fontSize: 20, // Increased font size for percentage
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}