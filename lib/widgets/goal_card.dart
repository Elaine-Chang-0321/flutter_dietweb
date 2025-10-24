import 'package:flutter/material.dart';

class GoalCard extends StatefulWidget {
  final int index;
  final String title;
  final int current;
  final int goal;
  final Color backgroundColor;

  const GoalCard({
    Key? key,
    required this.index,
    required this.title,
    required this.current,
    required this.goal,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Calculate progress
    double progress;
    Color progressBarColor = const Color(0xFF16A34A); // Default green

    if (widget.title == 'Junk Food') {
      if (widget.current == 0) {
        progress = 1.0;
        progressBarColor = const Color(0xFF16A34A); // Green
      } else {
        // progress = max(0, 1 - (current / 1)); // Simplified for now, assuming goal is 0 for junk food
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
          color: widget.backgroundColor,
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
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.index}.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18, // 18-20
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                height: 1.3,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Today: ',
                style: const TextStyle(
                  fontSize: 14, // 14-16
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: '${widget.current}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' / Goal: ${widget.goal} servings',
                  ),
                  if (showReduceIntake)
                    TextSpan(
                      text: ' (reduce intake)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                ],
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Semantics(
                label: '${widget.title} progress ${ (progress * 100).round()}%',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Rounded corners for progress bar
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                    minHeight: 12, // 10-12px
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}