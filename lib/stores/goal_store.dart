import 'dart:math';
import 'package:flutter/material.dart'; // Import for Color

class Goal {
  final int index;
  final String title;
  final int current;
  final int goal;
  final Color backgroundColor;

  Goal({
    required this.index,
    required this.title,
    required this.current,
    required this.goal,
    required this.backgroundColor,
  });
}

class GoalStore {
  // 固定目標值
  static const int wholeGrainsGoal = 5;
  static const int proteinGoal = 10;
  static const int vegetablesGoal = 3;
  static const int junkFoodGoal = 0; // 特殊處理，目標為0

  // 當日目前值，預設皆為 0
  int wholeGrainsCurrent = 2; // 範例數據
  int proteinCurrent = 7;     // 範例數據
  int vegetablesCurrent = 1;  // 範例數據
  int junkFoodCurrent = 1;    // 範例數據

  // 進度計算 - Whole Grains
  double get wholeGrainsProgress {
    // clamp 確保進度值在 0.0 到 1.0 之間
    return (wholeGrainsCurrent / wholeGrainsGoal).clamp(0.0, 1.0);
  }

  // 進度計算 - Protein
  double get proteinProgress {
    return (proteinCurrent / proteinGoal).clamp(0.0, 1.0);
  }

  // 進度計算 - Vegetables
  double get vegetablesProgress {
    return (vegetablesCurrent / vegetablesGoal).clamp(0.0, 1.0);
  }

  // 進度計算 - Junk Food
  // 根據 spec: progress = (current == 0 ? 1 : max(0, 1 - current))
  // 當 current > 0 時，進度條會顯示紅色。
  // 這裡的 '1.0' 似乎是作為隱含的「最大允許攝取量」來計算進度。
  double get junkFoodProgress {
    if (junkFoodCurrent == 0) {
      return 1.0; // 沒有攝取 Junk Food，進度 100%
    } else {
      // 攝取量大於 0 時，根據公式計算進度，並確保不小於 0。
      return max(0.0, 1.0 - junkFoodCurrent);
    }
  }

  // 判斷 Junk Food 是否超出目標，用於 UI 顯示紅色警示
  bool get isJunkFoodOverGoal {
    return junkFoodCurrent > junkFoodGoal;
  }

  Future<List<Goal>> fetchGoals() async {
    // 模擬網路請求延遲
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Goal(
        index: 1,
        title: "Whole Grains",
        current: wholeGrainsCurrent,
        goal: wholeGrainsGoal,
        backgroundColor: const Color(0xFFFEE2E2), // 粉彩色
      ),
      Goal(
        index: 2,
        title: "Protein",
        current: proteinCurrent,
        goal: proteinGoal,
        backgroundColor: const Color(0xFFDBEAFE), // 粉彩色
      ),
      Goal(
        index: 3,
        title: "Vegetables",
        current: vegetablesCurrent,
        goal: vegetablesGoal,
        backgroundColor: const Color(0xFFD1FAE5), // 粉彩色
      ),
      Goal(
        index: 4,
        title: "Junk Food",
        current: junkFoodCurrent,
        goal: junkFoodGoal,
        backgroundColor: const Color(0xFFFEF3C7), // 粉彩色
      ),
    ];
  }
}