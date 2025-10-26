class MealRecord {
  final int id;
  final DateTime createdAt;
  final DateTime date;
  final String meal;
  final int wholeGrains;
  final int vegetables;
  final int proteinLow;
  final int proteinMed;
  final int proteinHigh;
  final int proteinXHigh;
  final int junkFood;
  final String? note;
  final String? imageUrl;

  MealRecord({
    required this.id,
    required this.createdAt,
    required this.date,
    required this.meal,
    required this.wholeGrains,
    required this.vegetables,
    required this.proteinLow,
    required this.proteinMed,
    required this.proteinHigh,
    required this.proteinXHigh,
    required this.junkFood,
    this.note,
    this.imageUrl,
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      date: DateTime.parse(
        (json['date'] as String).replaceAll('/', '-'),
      ),
      meal: json['meal'],
      wholeGrains: json['whole_grains'] ?? 0,
      vegetables: json['vegetables'] ?? 0,
      proteinLow: json['protein_low'] ?? 0,
      proteinMed: json['protein_med'] ?? 0,
      proteinHigh: json['protein_high'] ?? 0,
      proteinXHigh: json['protein_xhigh'] ?? 0,
      junkFood: json['junk_food'] ?? 0,
      note: json['note'],
      imageUrl: json['image_url'],
    );
  }
}