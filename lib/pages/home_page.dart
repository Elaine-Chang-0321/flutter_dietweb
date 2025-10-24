import 'package:flutter/material.dart';
import 'package:flutter_dietweb/widgets/goal_card.dart';
import 'package:flutter_dietweb/stores/goal_store.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoalStore _goalStore = GoalStore();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600;
    final bool isTablet = screenSize.width >= 600 && screenSize.width < 1024;

    double horizontalPadding = 24.0;
    if (isTablet) {
      horizontalPadding = 48.0;
    } else if (!isMobile) {
      horizontalPadding = 72.0;
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Make Scaffold background transparent
      body: Column(
        children: [
          // Navigation Bar
          Container(
            height: 64,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Diet Web",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    _navButton(context, "Record Meal", isSelected: false),
                    const SizedBox(width: 24),
                    _navButton(context, "History", isSelected: false),
                  ],
                ),
              ],
            ),
          ),
          // Expanded section for background, overlay, and content
          Expanded(
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/back.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Semi-transparent overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                // Original content (Hero Section and Goal Cards Section)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hero Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 48.0 : 64.0,
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Your goals start with a meal.",
                              style: GoogleFonts.handlee(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Track your diet, achieve your health goals.",
                              style: GoogleFonts.handlee(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: const Color(0xFF111827), // Assuming Colors.black or a similar dark color
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // Goal Cards Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            SizedBox(height: isMobile ? 32 : 40),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1120),
                              child: FutureBuilder<List<Goal>>(
                                future: _goalStore.fetchGoals(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text('No goals found.'));
                                  } else {
                                    final goals = snapshot.data!;
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
                                        crossAxisSpacing: isMobile ? 0 : 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: isMobile ? (screenSize.width - horizontalPadding * 2) / 200 : 1,
                                      ),
                                      itemCount: goals.length,
                                      itemBuilder: (context, index) {
                                        final goal = goals[index];
                                        return GoalCard(
                                          index: goal.index,
                                          title: goal.title,
                                          current: goal.current,
                                          goal: goal.goal,
                                          backgroundColor: goal.backgroundColor,
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, String text, {bool isSelected = false}) {
    return TextButton(
      onPressed: () {
        // Handle navigation
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? const Color(0xFF111827) : const Color(0xFF374151),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.grey.withOpacity(0.1);
            }
            return null;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return const Color(0xFF111827);
            }
            return isSelected ? const Color(0xFF111827) : const Color(0xFF374151);
          },
        ),
        side: MaterialStateProperty.resolveWith<BorderSide?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return const BorderSide(color: Color(0xFF3B82F6), width: 2);
            }
            return BorderSide.none;
          },
        ),
      ),
      child: Text(text),
    );
  }
}