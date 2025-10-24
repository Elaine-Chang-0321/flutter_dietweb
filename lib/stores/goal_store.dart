import 'dart:math';
import 'package:flutter/material.dart'; // Import for Color
import 'package:collection/collection.dart'; // For partition

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

class DailyProgress {
  final DateTime date;
  final List<Goal> goals;

  DailyProgress({
    required this.date,
    required this.goals,
  }) : assert(goals.length == 4);
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

  // 修改為提供 List<DailyProgress> days
  List<DailyProgress> get days {
    // 模擬多天的數據
    final today = DateTime.now();
    final List<DailyProgress> dailyProgressList = [];

    for (int i = 0; i < 7; i++) { // 產生七天的數據
      final date = today.subtract(Duration(days: i));
      // 每個 DailyProgress 內含四個 Goal
      final goals = [
        Goal(
          index: 1,
          title: "Whole Grains",
          current: wholeGrainsCurrent + i, // 範例數據隨日期變化
          goal: wholeGrainsGoal,
          backgroundColor: const Color(0xFFFEE2E2),
        ),
        Goal(
          index: 2,
          title: "Protein",
          current: proteinCurrent + i,
          goal: proteinGoal,
          backgroundColor: const Color(0xFFDBEAFE),
        ),
        Goal(
          index: 3,
          title: "Vegetables",
          current: vegetablesCurrent + i,
          goal: vegetablesGoal,
          backgroundColor: const Color(0xFFD1FAE5),
        ),
        Goal(
          index: 4,
          title: "Junk Food",
          current: junkFoodCurrent + (i % 2), // 範例數據
          goal: junkFoodGoal,
          backgroundColor: const Color(0xFFFEF3C7),
        ),
      ];
      dailyProgressList.add(DailyProgress(date: date, goals: goals));
    }
    return dailyProgressList.reversed.toList(); // 讓日期由舊到新
  }

  // 原有的 fetchGoals 函數可以移除或修改，這裡暫時保留並修改其返回類型以適應新的數據結構
  // 如果 HomePage 不再直接使用此函數，可以考慮移除。
  Future<List<Goal>> fetchGoals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 返回最新一天的目標列表
    return days.last.goals;
  }
}