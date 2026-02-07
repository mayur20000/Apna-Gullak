import '../models/app_user.dart';

class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }

    _currentUser = AppUser(
      id: email.hashCode.toString(),
      email: email,
      displayName: email.split('@').first,
    );

    return _currentUser!;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}
