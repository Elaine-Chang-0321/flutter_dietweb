import 'dart:math';
import 'package:flutter/material.dart'; // Import for Color
import 'package:flutter_dietweb/models/day_totals.dart';
import 'package:flutter_dietweb/services/api_client.dart';
import 'package:intl/intl.dart';

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

class GoalStore with ChangeNotifier {
  // 固定目標值
  static const int wholeGrainsGoal = 5;
  static const int proteinGoal = 10;
  static const int vegetablesGoal = 3;
  static const int junkFoodGoal = 0; // 特殊處理，目標為0

  bool isLoading = false;
  String? errorMessage;
  List<DayTotals> _dayTotals = [];

  // 當日目前值，預設皆為 0
  int wholeGrainsCurrent = 0;
  int proteinCurrent = 0;
  int vegetablesCurrent = 0;
  int junkFoodCurrent = 0;

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

  List<DailyProgress> get days {
    final List<DailyProgress> dailyProgressList = [];

    for (var dayTotal in _dayTotals) {
      final goals = [
        Goal(
          index: 1,
          title: "Whole Grains",
          current: dayTotal.wholeGrains,
          goal: wholeGrainsGoal,
          backgroundColor: const Color(0xFFFEE2E2),
        ),
        Goal(
          index: 2,
          title: "Protein",
          current: dayTotal.proteinTotal,
          goal: proteinGoal,
          backgroundColor: const Color(0xFFDBEAFE),
        ),
        Goal(
          index: 3,
          title: "Vegetables",
          current: dayTotal.vegetables,
          goal: vegetablesGoal,
          backgroundColor: const Color(0xFFD1FAE5),
        ),
        Goal(
          index: 4,
          title: "Junk Food",
          current: dayTotal.junkFood,
          goal: junkFoodGoal,
          backgroundColor: const Color(0xFFFEF3C7),
        ),
      ];
      dailyProgressList.add(DailyProgress(date: dayTotal.date, goals: goals));
    }
    return dailyProgressList;
  }

  Future<void> loadDays({required DateTime from, required DateTime to}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _dayTotals.clear();
      for (int i = 0; i <= to.difference(from).inDays; i++) {
        final date = from.add(Duration(days: i));
        try {
          final json = await ApiClient.fetchDailySummary(date);
          _dayTotals.add(DayTotals.fromJson({
            'date': DateFormat('yyyy-MM-dd').format(date), // 使用 DateFormat 格式化日期
            'whole_grains': json['whole_grains'] ?? 0,
            'vegetables': json['vegetables'] ?? 0,
            'protein_total': json['protein_total'] ?? 0,
            'junk_food': json['junk_food'] ?? 0,
          }));
        } catch (e) {
          // 如果某一天沒有資料，就當作 0
          _dayTotals.add(DayTotals.fromJson({
            'date': DateFormat('yyyy-MM-dd').format(date),
            'whole_grains': 0,
            'vegetables': 0,
            'protein_total': 0,
            'junk_food': 0,
          }));
        }
      }

      // Update current values for the latest day if available
      if (_dayTotals.isNotEmpty) {
        final latestDay = _dayTotals.last;
        wholeGrainsCurrent = latestDay.wholeGrains;
        proteinCurrent = latestDay.proteinTotal;
        vegetablesCurrent = latestDay.vegetables;
        junkFoodCurrent = latestDay.junkFood;
      } else {
        wholeGrainsCurrent = 0;
        proteinCurrent = 0;
        vegetablesCurrent = 0;
        junkFoodCurrent = 0;
      }
    } catch (e) {
      errorMessage = e.toString();
      _dayTotals = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // The fetchGoals method can be removed as Home page will now use `days` getter directly.
  // Keeping it for now to avoid breaking existing code, but it should be refactored.
  Future<List<Goal>> fetchGoals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // If _dayTotals is empty, return an empty list or throw an error.
    if (_dayTotals.isEmpty) {
      return [];
    }
    return days.last.goals;
  }
}