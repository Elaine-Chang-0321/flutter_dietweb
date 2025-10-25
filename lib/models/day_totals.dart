import 'package:flutter/material.dart';

class DayTotals {
  final DateTime date;
  final int wholeGrains;
  final int vegetables;
  final int proteinTotal;
  final int junkFood;

  const DayTotals({
    required this.date,
    required this.wholeGrains,
    required this.vegetables,
    required this.proteinTotal,
    required this.junkFood,
  });

  factory DayTotals.fromJson(Map<String, dynamic> j) {
    return DayTotals(
      date: DateTime.parse(j['date']),
      wholeGrains: int.tryParse(j['whole_grains']?.toString() ?? '0') ?? 0,
      vegetables: int.tryParse(j['vegetables']?.toString() ?? '0') ?? 0,
      proteinTotal: int.tryParse(j['protein_total']?.toString() ?? '0') ?? 0,
      junkFood: int.tryParse(j['junk_food']?.toString() ?? '0') ?? 0,
    );
  }
}