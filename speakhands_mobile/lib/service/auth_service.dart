import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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

  // Login con Facebook + registro en DB + eventos gfhjgfre
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success || result.accessToken == null) {
        print('Facebook login falló: ${result.status}');
        return null;
      }

      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      final bool isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (user != null) {
        // Guardar en Realtime Database si es nuevo
        if (isNew) {
          await _saveUserData(user);
        }

        print('Facebook login exitoso para ${user.email}');
      }

      return {
        'userCredential': userCredential,
        'isNew': isNew,
        'createdAt': user?.metadata.creationTime,
      };
    } catch (e) {
      print("Error en login con Facebook: $e");
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

  // Login with email and password
  Future<UserCredential?> logIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error during login: $e");
      rethrow;
    }
  }

  // Get current auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Log Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }
}
