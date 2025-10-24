import 'package:flutter/material.dart';
import 'package:flutter_dietweb/widgets/goal_card.dart';
import 'package:flutter_dietweb/stores/goal_store.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 為了使用 context.read

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageCtrl;
  int _pageIndex = 0;


  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

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

final df = DateFormat('yyyy/MM/dd');
    final days = context.watch<GoalStore>().days; // 依你的狀態管理方式取用

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
                              child: Column(
                                children: [
                                  // 日期 + 左右箭頭
// 日期列與左右箭頭
Padding(
 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
 child: Row(
   children: [
     Text(
       df.format(days[_pageIndex].date),
       style: Theme.of(context).textTheme.titleLarge,
     ),
     const Spacer(),
     IconButton(
       tooltip: 'Previous',
       onPressed: _pageIndex > 0
           ? () {
               _pageCtrl.animateToPage(
                 _pageIndex - 1,
                 duration: const Duration(milliseconds: 250),
                 curve: Curves.easeOut,
               );
             }
           : null,
       icon: const Icon(Icons.chevron_left),
     ),
     IconButton(
       tooltip: 'Next',
       onPressed: _pageIndex < days.length - 1
           ? () {
               _pageCtrl.animateToPage(
                 _pageIndex + 1,
                 duration: const Duration(milliseconds: 250),
                 curve: Curves.easeOut,
               );
             }
           : null,
       icon: const Icon(Icons.chevron_right),
     ),
   ],
 ),
),

// 一頁 4 張卡片，橫向排列
SizedBox(
 height: 300, // 卡片高度調低，畫面更平衡
 child: PageView.builder(
   controller: _pageCtrl,
   itemCount: days.length,
   onPageChanged: (i) => setState(() => _pageIndex = i),
   itemBuilder: (context, index) {
     final day = days[index];
     final goals = day.goals; // 必須是 4 筆資料

     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Expanded(
             child: GoalCard(
               title: goals[0].title,
               current: goals[0].current,
               goal: goals[0].goal,
               backgroundColor: goals[0].backgroundColor,
             ),
           ),
           const SizedBox(width: 24),
           Expanded(
             child: GoalCard(
               title: goals[1].title,
               current: goals[1].current,
               goal: goals[1].goal,
               backgroundColor: goals[1].backgroundColor,
             ),
           ),
           const SizedBox(width: 24),
           Expanded(
             child: GoalCard(
               title: goals[2].title,
               current: goals[2].current,
               goal: goals[2].goal,
               backgroundColor: goals[2].backgroundColor,
             ),
           ),
           const SizedBox(width: 24),
           Expanded(
             child: GoalCard(
               title: goals[3].title,
               current: goals[3].current,
               goal: goals[3].goal,
               backgroundColor: goals[3].backgroundColor,
             ),
           ),
         ],
       ),
     );
   },
 ),
),
                                ],
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