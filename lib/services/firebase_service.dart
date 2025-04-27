import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<User?> signUp(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(displayName);
      return result.user;
    } catch (e) {
      throw Exception('Sign-up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Sign-in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateProfile(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Get user goals as a stream
  Stream<List<Goal>> getUserGoals() {
    User? user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Goal.fromJson(doc.data())).toList());
  }

  // Add a new goal
  Future<void> addGoal(Goal goal) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await _firestore.collection('goals').doc(goal.id).set({
      ...goal.toJson(),
      'userId': user.uid,
    });
  }

  // Update goal amount
  Future<void> updateGoalAmount(String goalId, double amount) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    DocumentSnapshot doc =
    await _firestore.collection('goals').doc(goalId).get();
    if (!doc.exists) throw Exception('Goal not found');
    double currentAmount = (doc['savedAmount'] as num).toDouble();
    await _firestore.collection('goals').doc(goalId).update({
      'savedAmount': currentAmount + amount,
      'isCompleted': (currentAmount + amount) >= (doc['targetAmount'] as num),
    });
  }

  // Redeem a goal
  Future<void> redeemGoal(String goalId) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await _firestore.collection('goals').doc(goalId).update({
      'isLocked': false,
      'isCompleted': true,
    });
  }
}