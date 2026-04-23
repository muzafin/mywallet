// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Cek apakah user sudah login
  Stream<User?> get user => _auth.authStateChanges();

  // Login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      // Mulai proses login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // User batal login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print('Error login dengan Google: $e');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Mendapatkan user ID saat ini
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Mendapatkan nama user
  String? getCurrentUserName() {
    return _auth.currentUser?.displayName ?? _auth.currentUser?.email;
  }

  // Mendapatkan email user
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }
}
