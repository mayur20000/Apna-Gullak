import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/goal.dart';
import 'state/app_state.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const ApnaGullakApp());
}

class ApnaGullakApp extends StatefulWidget {
  const ApnaGullakApp({super.key});

  @override
  State<ApnaGullakApp> createState() => _ApnaGullakAppState();
}

class _ApnaGullakAppState extends State<ApnaGullakApp> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState(AuthService());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apna Gullak',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: AnimatedBuilder(
        animation: _state,
        builder: (context, _) {
          if (!_state.isAuthenticated) {
            return SignInScreen(state: _state);
          }
          return HomeScreen(state: _state);
        },
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sign in', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    try {
                      await widget.state.signIn(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );
                    } catch (e) {
                      setState(() => _error = e.toString());
                    }
                  },
                  child: const Text('Continue'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});

  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardTab(state: widget.state),
      GoalsTab(state: widget.state),
      TransactionsTab(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${widget.state.displayName}'),
        actions: [
          IconButton(
            onPressed: widget.state.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Transactions'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: const Text('Wallet Balance'),
              subtitle: Text(
                formatter.format(state.walletBalance),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Active goals: ${state.goals.length}'),
        ],
      ),
    );
  }
}

class GoalsTab extends StatefulWidget {
  const GoalsTab({super.key, required this.state});

  final AppState state;

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _fundsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Goal title'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target ₹'),
                ),
              ),
              IconButton(
                onPressed: () {
                  final target = int.tryParse(_targetController.text) ?? 0;
                  widget.state.createGoal(
                    title: _titleController.text,
                    targetAmount: target,
                  );
                  _titleController.clear();
                  _targetController.clear();
                },
                icon: const Icon(Icons.add_circle),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.state.goals.length,
            itemBuilder: (context, index) {
              final goal = widget.state.goals[index];
              return GoalCard(
                goal: goal,
                onAddFunds: (amount) =>
                    widget.state.addFundsToGoal(goalId: goal.id, amount: amount),
                fundsController: _fundsController,
              );
            },
          ),
        ),
      ],
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.onAddFunds,
    required this.fundsController,
  });

  final Goal goal;
  final void Function(int amount) onAddFunds;
  final TextEditingController fundsController;

  @override
  Widget build(BuildContext context) {
    final progress = goal.savedAmount / goal.targetAmount;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
            const SizedBox(height: 8),
            Text('₹${goal.savedAmount} / ₹${goal.targetAmount}'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fundsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Add funds ₹'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final amount = int.tryParse(fundsController.text) ?? 0;
                    onAddFunds(amount);
                    fundsController.clear();
                  },
                  icon: const Icon(Icons.payments),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.transactions.isEmpty) {
      return const Center(child: Text('No transactions yet'));
    }

    return ListView.builder(
      itemCount: state.transactions.length,
      itemBuilder: (context, index) {
        final txn = state.transactions[index];
        return ListTile(
          leading: const Icon(Icons.arrow_downward, color: Colors.green),
          title: Text(txn.note),
          subtitle: Text(txn.createdAt.toLocal().toString()),
          trailing: Text('₹${txn.amount}'),
        );
      },
    );
  }
}
