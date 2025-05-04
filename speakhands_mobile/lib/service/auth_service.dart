import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Uso del ref()

  // Método para iniciar sesión o registrar con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Iniciar sesión con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear credenciales de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión o registrar al usuario
      final userCredential = await _auth.signInWithCredential(credential);

      // Si es el primer inicio de sesión, guardar los datos en Realtime Database
      if (userCredential.user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _saveUserData(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
      return null;
    }
  }

  // Guardar los datos del usuario en Firebase Realtime Database
  Future<void> _saveUserData(User user) async {
    try {
      // Crear la estructura de datos para el usuario
      await _database.child('usuarios').child(user.uid).set({
        'nombre': user.displayName,
        'email': user.email,
        'foto': user.photoURL,
      });
      print('Datos del usuario guardados en Firebase Realtime Database.');
    } catch (e) {
      print("Error al guardar datos en Realtime Database: $e");
    }
  }

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
