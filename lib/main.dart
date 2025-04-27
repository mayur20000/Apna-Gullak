import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/goal.dart';
import 'screens/auth_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/home_screen.dart';
import 'screens/investments_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/transactions_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ApnaGullakApp());
}

class ApnaGullakApp extends StatelessWidget {
  const ApnaGullakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apna Gullak',
      theme: ThemeData(
        primaryColor: const Color(0xFF26A69A),
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF26A69A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF26A69A),
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF26A69A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();
  double walletBalance = 100.0; // Mock wallet balance

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens.addAll([
      const HomeScreen(),
      const GoalsScreen(),
      const TransactionsScreen(),
      const InvestmentsScreen(),
      const ProfileScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showAddGoalDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final targetAmountController = TextEditingController();
    final daysController = TextEditingController();
    DateTime? selectedDate;

    final suggestions = [
      {'title': 'Buy a Bag', 'price': 50.0},
      {'title': 'New Phone', 'price': 300.0},
      {'title': 'Vacation Trip', 'price': 500.0},
    ];
    int suggestionIndex = 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphicContainer(
          width: 320,
          height: 450,
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
          borderGradient:
          const LinearGradient(colors: [Colors.white24, Colors.white10]),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create New Goal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Goal Name (e.g., Buy a Bag)',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter a goal name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: targetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Target Amount',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ||
                          double.tryParse(value) == null ||
                          double.parse(value) <= 0
                          ? 'Please enter a valid amount'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          selectedDate = date;
                          daysController.text =
                          '${date.difference(DateTime.now()).inDays} days';
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: daysController,
                          decoration: const InputDecoration(
                            labelText: 'Target Date (Optional)',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            titleController.text =
                                suggestions[suggestionIndex]['title']!.toString();
                            targetAmountController.text = suggestions[suggestionIndex]
                            ['price']!
                                .toString();
                            suggestionIndex =
                                (suggestionIndex + 1) % suggestions.length;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text(
                            'Suggest Goal',
                            style: TextStyle(color: Color(0xFF26A69A)),
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final title = titleController.text;
                              final targetAmount =
                              double.parse(targetAmountController.text);
                              try {
                                await _firebaseService.addGoal(Goal(
                                  id: DateTime.now().toString(),
                                  title: title,
                                  targetAmount: targetAmount,
                                  targetDate: selectedDate,
                                ));
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Goal "$title" created')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF26A69A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Save'),
                        ).animate().fadeIn(duration: 300.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26A69A), Color(0xFF00796B)],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _screens[_selectedIndex],
          bottomNavigationBar: GlassmorphicContainer(
            width: double.infinity,
            height: 70, // Reduced height to prevent overflow
            borderRadius: 15,
            blur: 20,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient:
            const LinearGradient(colors: [Colors.black54, Colors.black38]),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: 'Transactions'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.trending_up), label: 'Investments'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
          floatingActionButton: _selectedIndex == 1
              ? FloatingActionButton(
            onPressed: () => _showAddGoalDialog(context),
            backgroundColor: Colors.white,
            elevation: 10,
            child: const Icon(Icons.add, color: Color(0xFF26A69A)),
          ).animate().scale(duration: 500.ms)
              : null,
        ),
      ),
    );
  }
}