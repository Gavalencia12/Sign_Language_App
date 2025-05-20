import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // ========== EMAIL/CODE VERIFICATION REGISTRATION FLOW ==========

  // 1. Generar y guardar código en la base de datos
  Future<void> sendVerificationCode(String email) async {
    final String code = (10000 + Random().nextInt(90000)).toString(); // Código de 5 dígitos
    final String safeEmail = email.replaceAll('.', '_');

    try {
      await _database.child('verifications/$safeEmail').set({'code': code});
      print('Código enviado a $email: $code');
      // Aquí va el envío real del correo si tienes backend
    } catch (e) {
      print("Error al enviar código: $e");
      rethrow;
    }
  }

  // 2. Verificar el código ingresado por el usuario
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

  // 3. Crear cuenta de usuario con email y contraseña
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

  // ========== DATOS EN REALTIME DATABASE ==========

  Future<void> _saveUserData(User user) async {
    try {
      // Crear la estructura de datos para el usuario
      await _database.child('usuarios').child(user.uid).set({
        'nombre': user.displayName ?? '', // Si es con email normal puede estar vacío
        'email': user.email,
        'foto': user.photoURL ?? '',
      });
      print('Datos del usuario guardados correctamente');
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
