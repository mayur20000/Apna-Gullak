import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/goal.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26A69A), Color(0xFF00796B)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Apna Gullak', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: StreamBuilder<List<Goal>>(
          stream: firebaseService.getUserGoals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final goals = snapshot.data ?? [];
            double totalSaved =
            goals.fold(0.0, (sum, goal) => sum + goal.savedAmount);
            double walletBalance = 100.0; // Mock wallet balance
            return SingleChildScrollView(
              child: Column(
                children: [
                  GlassmorphicContainer(
                    width: double.infinity,
                    height: 250,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderGradient: const LinearGradient(
                        colors: [Colors.white24, Colors.white10]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Total Locked Savings',
                            style:
                            TextStyle(color: Colors.white70, fontSize: 18)),
                        const SizedBox(height: 20),
                        CircularProgressIndicator(
                          value: totalSaved /
                              (goals.isEmpty
                                  ? 1
                                  : goals.fold(
                                  0.0, (sum, g) => sum + g.targetAmount)),
                          strokeWidth: 15,
                          backgroundColor: Colors.white24,
                          valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                        ).animate().scale(duration: 800.ms),
                        const SizedBox(height: 20),
                        Text('\$${totalSaved.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('Wallet: \$${walletBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.greenAccent, fontSize: 16)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Goals',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...goals.map((goal) => GoalCard(goal: goal)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 15,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      borderGradient:
      const LinearGradient(colors: [Colors.white24, Colors.white10]),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.flight, color: Colors.white70, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(goal.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ).animate().slideX(duration: 600.ms),
                  const SizedBox(height: 5),
                  Text(
                      '\$${goal.savedAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.5, end: 0, duration: 500.ms);
  }
}