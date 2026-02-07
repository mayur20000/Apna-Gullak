import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/goal.dart';
import '../models/transaction_entry.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  AppState(this._authService);

  final AuthService _authService;
  final List<Goal> _goals = [];
  final List<TransactionEntry> _transactions = [];

  int _walletBalance = 0;

  bool get isAuthenticated => _authService.currentUser != null;
  String get displayName => _authService.currentUser?.displayName ?? 'Guest';
  int get walletBalance => _walletBalance;
  List<Goal> get goals => List.unmodifiable(_goals);
  List<TransactionEntry> get transactions =>
      List.unmodifiable(_transactions.reversed);

  Future<void> signIn({required String email, required String password}) async {
    await _authService.signIn(email: email, password: password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  void createGoal({required String title, required int targetAmount}) {
    if (title.trim().isEmpty || targetAmount <= 0) {
      throw Exception('Valid title and target amount are required.');
    }

    final now = DateTime.now();
    _goals.add(
      Goal(
        id: _randomId(),
        title: title.trim(),
        targetAmount: targetAmount,
        savedAmount: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
    notifyListeners();
  }

  void addFundsToGoal({required String goalId, required int amount}) {
    if (amount <= 0) {
      throw Exception('Amount should be greater than zero.');
    }

    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex < 0) {
      throw Exception('Goal not found.');
    }

    final goal = _goals[goalIndex];
    final newSavedAmount = min(goal.savedAmount + amount, goal.targetAmount);
    final creditedAmount = newSavedAmount - goal.savedAmount;

    _goals[goalIndex] = goal.copyWith(
      savedAmount: newSavedAmount,
      updatedAt: DateTime.now(),
    );

    _walletBalance += creditedAmount;

    _transactions.add(
      TransactionEntry(
        id: _randomId(),
        goalId: goal.id,
        amount: creditedAmount,
        type: TransactionType.credit,
        status: TransactionStatus.success,
        createdAt: DateTime.now(),
        note: 'Added funds to ${goal.title}',
      ),
    );

    notifyListeners();
  }

  String _randomId() => DateTime.now().microsecondsSinceEpoch.toString();
}
