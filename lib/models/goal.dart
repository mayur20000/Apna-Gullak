class Goal {
  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final int targetAmount;
  final int savedAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => savedAmount >= targetAmount;

  Goal copyWith({
    String? id,
    String? title,
    int? targetAmount,
    int? savedAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
