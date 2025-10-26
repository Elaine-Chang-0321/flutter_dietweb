import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalCard extends StatefulWidget {
  final String title;
  final int current;
  final int goal;
  final Color? backgroundColor; // Make background color optional
  final bool showCircularProgress; // New parameter to control circular progress visibility
  final bool isMobileView; // New parameter to adjust font size for mobile view

  const GoalCard({
    Key? key,
    required this.title,
    required this.current,
    required this.goal,
    this.backgroundColor, // Make background color optional
    this.showCircularProgress = true, // Default to true
    this.isMobileView = false, // Default to false
  }) : super(key: key);

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // final bool isMobile = MediaQuery.of(context).size.width < 600; // Use widget.isMobileView instead

    // Define background colors based on title
Color cardBackgroundColor;
    Color textColor; // This will be the base text color for title and default numerical value
    Color defaultProgressBarColor; // This will be the default progress bar color based on title

    switch (widget.title.trim()) { // Add .trim() to handle potential leading/trailing spaces
      case 'Whole Grains':
        cardBackgroundColor = const Color(0xFFF5E8CF); // 里昂米白
        textColor = Colors.black87; // Dark text for light background
        defaultProgressBarColor = const Color(0xFF16A34A); // Green
        break;
      case 'Protein':
        cardBackgroundColor = const Color(0xFFEFC3BD); // 貴婦粉紅
        textColor = Colors.black87; // Dark text for light background
        defaultProgressBarColor = const Color(0xFF16A34A); // Green
        break;
      case 'Vegetables':
        cardBackgroundColor = const Color(0xFFEEE2D3); // 新的背景色
        textColor = const Color(0xFF000000); // 純黑色
        defaultProgressBarColor = const Color(0xFF16A34A); // Green
        break;
      case 'Junk Food':
        cardBackgroundColor = const Color(0xFFDED3D6); // 高貴黏土
        textColor = Colors.black87; // Dark text for light background
        defaultProgressBarColor = const Color(0xFFEF4444); // Red (this will be overridden later if current is 0)
        break;
      default:
        cardBackgroundColor = widget.backgroundColor ?? const Color(0xFFE0E0E0); // Fallback to a default grey if not matched and original is null
        textColor = const Color(0xFF111827);
        defaultProgressBarColor = const Color(0xFF16A34A);
    }

    // Calculate raw progress for conditional styling
    // Determine the actual progress value for CircularProgressIndicator (clamped)
    // and the final progress bar color and numerical text color
    double progress = 0.0;
    Color finalProgressBarColor = defaultProgressBarColor; // Initialize with a default
    Color finalNumericalAndPercentageTextColor = textColor; // Initialize with a default
    double displayPercentageValue = 0.0;

    if (widget.title.trim() == 'Junk Food') {
      if (widget.goal == 0) {
        if (widget.current > 0) {
          // Junk Food: current > 0 且 goal == 0 時，顯示 100% (紅色)
          displayPercentageValue = 1.0;
          progress = 1.0;
          finalProgressBarColor = const Color(0xFFEF4444); // 紅色
          finalNumericalAndPercentageTextColor = Colors.red; // 紅色文字
        } else {
          // Junk Food: current == 0 且 goal == 0 時，顯示 0% (綠色)
          displayPercentageValue = 0.0;
          progress = 0.0;
          finalProgressBarColor = const Color(0xFF16A34A); // 綠色
          finalNumericalAndPercentageTextColor = textColor; // 預設文字顏色
        }
      } else { // widget.goal > 0
        double rawCalculatedPercentage = widget.current / widget.goal;
        if (rawCalculatedPercentage > 1.0) {
          // Junk Food: goal > 0 且 current > goal 時，顯示 100% (紅色)
          displayPercentageValue = 1.0;
          progress = 1.0;
          finalProgressBarColor = const Color(0xFFEF4444); // 紅色
          finalNumericalAndPercentageTextColor = Colors.red; // 紅色文字
        } else {
          // Junk Food: 正常情況 (goal > 0 且 current <= goal)
          displayPercentageValue = rawCalculatedPercentage;
          progress = rawCalculatedPercentage.clamp(0.0, 1.0);
          finalProgressBarColor = const Color(0xFF16A34A); // 綠色
          finalNumericalAndPercentageTextColor = textColor; // 預設文字顏色
        }
      }
    } else {
      // 其他類別的現有邏輯保持不變
      double rawProgress = (widget.goal == 0) ? 0.0 : (widget.current / widget.goal);
      bool isOver100Percent = rawProgress > 1.0;

      progress = rawProgress.clamp(0.0, 1.0); // 限制在0.0到1.0之間用於顯示
      displayPercentageValue = rawProgress; // 其他類別的預設顯示百分比
      if (isOver100Percent) {
        finalProgressBarColor = Colors.red; // 超過100%時為紅色
        finalNumericalAndPercentageTextColor = Colors.red; // 超過100%時文字為紅色
      } else {
        finalProgressBarColor = defaultProgressBarColor; // 預設綠色
        finalNumericalAndPercentageTextColor = textColor; // 預設文字顏色
      }
    }

    // Determine if "reduce intake" text should be shown
    bool showReduceIntake = widget.title.trim() == 'Junk Food' && widget.current > 0 && !widget.isMobileView;

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
        padding: EdgeInsets.fromLTRB(24, 24, 24, widget.isMobileView ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.isMobileView && widget.title.trim() == 'Whole Grains'
                  ? 'W.Grains'
                  : widget.isMobileView && widget.title.trim() == 'Vegetables'
                      ? 'Vegetable'
                      : widget.title,
              style: GoogleFonts.fredoka(
                fontSize: widget.isMobileView ? 20 : 28, // Adjust font size based on isMobileView
                fontWeight: FontWeight.w700,
                color: textColor, // Apply the determined text color
                height: 1.3,
              ),
              textAlign: widget.isMobileView ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: '${widget.current}',
                style: GoogleFonts.fredoka(
                  fontSize: widget.isMobileView ? 20 : 28, // Adjust font size based on isMobileView
                  color: finalNumericalAndPercentageTextColor, // Adjusted to match title color
                  height: 1.3, // Adjusted for better vertical alignment
                  fontWeight: FontWeight.bold, // Set to bold
                ),
                children: [
                  TextSpan(
                    text: ' / ${widget.goal}',
                    style: GoogleFonts.fredoka(
                      fontSize: widget.isMobileView ? 20 : 28, // Adjust font size based on isMobileView
                      color: finalNumericalAndPercentageTextColor, // Adjusted to match title color
                      height: 1.3, // Adjusted for better vertical alignment
                      fontWeight: FontWeight.bold, // Set to bold
                    ),
                  ),
                  if (showReduceIntake)
                    TextSpan(
                      text: ' (reduce intake)',
                      style: GoogleFonts.fredoka(
                        fontSize: widget.isMobileView ? 10 : 12, // Adjust font size based on isMobileView
                        color: textColor.withOpacity(0.9), // Adjust color for warning text
                      ),
                    ),
                ],
              ),
              textAlign: TextAlign.center, // Centered alignment
            ),
            const Spacer(),
            if (widget.showCircularProgress)
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
                        valueColor: AlwaysStoppedAnimation<Color>(finalProgressBarColor),
                        strokeWidth: 16.0, // Increased strokeWidth for larger indicator
                      ),
                      Center(
                        child: Text(
                          '${(displayPercentageValue * 100).round()}%', // Display calculated percentage here
                          style: GoogleFonts.fredoka(
                            fontSize: widget.isMobileView ? 16 : 20, // Adjust font size based on isMobileView
                            fontWeight: FontWeight.w700,
                            color: finalNumericalAndPercentageTextColor, // Apply final text color
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