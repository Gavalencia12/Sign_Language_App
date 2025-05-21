import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

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

  // Save user data to Firebase Realtime Database
  Future<void> _saveUserData(User user) async {
    try {
      // Create the data structure for the user
      await _database.child('usuarios').child(user.uid).set({
        'nombre': user.displayName,
        'email': user.email,
        'foto': user.photoURL,
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
