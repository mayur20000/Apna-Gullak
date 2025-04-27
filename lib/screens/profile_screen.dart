import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();
    final user = firebaseService.currentUser;
    final walletBalance = 100.0; // Mock wallet balance
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
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: double.infinity,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child:
                    const Icon(Icons.person, size: 50, color: Colors.white),
                  ).animate().scale(duration: 600.ms),
                  const SizedBox(height: 20),
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: const Icon(
                        Icons.account_balance_wallet, color: Colors.white70),
                    title: const Text('Wallet Balance',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text('\$${walletBalance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.greenAccent)),
                  ).animate().fadeIn(duration: 500.ms),
                  ListTile(
                    leading:
                    const Icon(Icons.notifications, color: Colors.white70),
                    title: const Text('Notifications',
                        style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                        value: true,
                        onChanged: (val) {},
                        activeColor: Colors.white),
                  ).animate().fadeIn(duration: 500.ms),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await firebaseService.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Logout',
                        style: TextStyle(color: Colors.white)),
                  ).animate().scale(duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}