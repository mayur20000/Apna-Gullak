enum TransactionType { credit, debit }
enum TransactionStatus { success, failed }

class TransactionEntry {
  TransactionEntry({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.note,
  });

  final String id;
  final String goalId;
  final int amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime createdAt;
  final String note;
}
