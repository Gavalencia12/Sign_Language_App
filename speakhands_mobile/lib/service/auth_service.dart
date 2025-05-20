import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Uso del ref()

// Method to log in or register with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Google credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Log in or register the user
      final userCredential = await _auth.signInWithCredential(credential);

      // If this is the first login, save the data to Realtime Database
      if (userCredential.user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _saveUserData(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  // ========== EMAIL/CODE VERIFICATION REGISTRATION FLOW ==========

  // 1. Generate and save code to the database
  Future<void> sendVerificationCode(String email) async {
    final String code = (10000 + Random().nextInt(90000)).toString(); // Código de 5 dígitos
    final String safeEmail = email.replaceAll('.', '_');

    try {
      await _database.child('verifications/$safeEmail').set({'code': code});
      print('Código enviado a $email: $code');
      // Here goes the actual mail sending if you have a backend
    } catch (e) {
      print("Error al enviar código: $e");
      rethrow;
    }
  }

  // 2. Verify the code entered by the user
  Future<bool> verifyCode(String email, String inputCode) async {
    final String safeEmail = email.replaceAll('.', '_');
    final DataSnapshot snapshot = await _database.child('verifications/$safeEmail/code').get();

    if (snapshot.exists && snapshot.value.toString() == inputCode) {
      await _database.child('verifications/$safeEmail').remove(); // borra tras validar
      return true;
    } else {
      return false;
    }
  }

  // 3. Create a user account with email and password
  Future<UserCredential?> createUserWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _saveUserData(userCredential.user!);
      return userCredential;
    } catch (e) {
      print("Error al crear cuenta: $e");
      rethrow;
    }
  }
  
  Future<List<String>> fetchSignInMethods(String email) async {
    try {
      return await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    } catch (e) {
      print("Error checking email: $e");
      rethrow;
    }
  }

  // ========== DATA IN REALTIME DATABASE ==========

  Future<void> _saveUserData(User user) async {
    try {
      // Create the data structure for the user
      await _database.child('usuarios').child(user.uid).set({
        'nombre': user.displayName ?? '', // If it is with normal email it can be empty
        'email': user.email,
        'foto': user.photoURL ?? '',
      });
      print('User data stored in the Firebase Realtime Database.');
    } catch (e) {
      print("Error saving data to Realtime Database: $e");
    }
  }

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Log out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
