import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Login or registration with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

      // Save to database if new
      if (user != null && isNew) {
        await _saveUserData(user);
      }

      return {
        'userCredential': userCredential,
        'isNew': isNew,
        'createdAt': user?.metadata.creationTime,
      };
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }


  // Send verification code (email)
  Future<void> sendVerificationCode(String email) async {
    final String code = (10000 + Random().nextInt(90000)).toString();
    final String safeEmail = email.replaceAll('.', '_');

    try {
      await _database.child('verifications/$safeEmail').set({'code': code});
      print('Código enviado a $email: $code');
      
    } catch (e) {
      print("Error al enviar código: $e");
      rethrow;
    }
  }

  // Code verification
  Future<bool> verifyCode(String email, String inputCode) async {
    final String safeEmail = email.replaceAll('.', '_');
    final DataSnapshot snapshot = await _database.child('verifications/$safeEmail/code').get();

    if (snapshot.exists && snapshot.value.toString() == inputCode) {
      await _database.child('verifications/$safeEmail').remove();
      return true;
    } else {
      return false;
    }
  }

  // Create account with email and password
  Future<UserCredential?> createUserWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Instead of using .set, use .update to avoid overwriting if the node exists
      await _database.child('usuarios').child(userCredential.user!.uid).update({
        'nombre': userCredential.user!.displayName ?? '',
        'email': userCredential.user!.email,
        'foto': userCredential.user!.photoURL ?? '',
      });

      return userCredential;
    } catch (e) {
      print("Error al crear cuenta: $e");
      rethrow;
    }
  }

  // Get login methods for email
  Future<List<String>> fetchSignInMethods(String email) async {
    try {
      return await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    } catch (e) {
      print("Error checking email: $e");
      rethrow;
    }
  }

  // Save initial user data (used for Google Sign In)
  Future<void> _saveUserData(User user) async {
    try {
      await _database.child('usuarios').child(user.uid).update({
        'nombre': user.displayName ?? '',
        'email': user.email,
        'foto': user.photoURL ?? '',
      });
      print('User data stored in Firebase Realtime Database.');
    } catch (e) {
      print("Error saving data to Realtime Database: $e");
    }
  }

  // Current user
  User? get currentUser => _auth.currentUser;

  // Log Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
