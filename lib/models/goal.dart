class Goal {
  final String id;
  final String title;
  final double targetAmount;
  double savedAmount;
  bool isCompleted;
  bool isLocked;
  final DateTime? targetDate;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    this.isCompleted = false,
    this.isLocked = true,
    this.targetDate,
  });

  bool get canRedeem => savedAmount >= targetAmount && !isLocked;

  double get progress => savedAmount / targetAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num).toDouble(),
      isCompleted: json['isCompleted'],
      isLocked: json['isLocked'] as bool,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
    );
  }
}