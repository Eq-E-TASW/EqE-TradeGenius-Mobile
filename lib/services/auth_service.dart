import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro de usuario con email y contraseña
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('La contraseña es muy débil.');
      } else if (e.code == 'email-already-in-use') {
        print('Ya existe una cuenta con este correo.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Login de usuario con email y contraseña
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No se encontró un usuario con ese correo.');
      } else if (e.code == 'wrong-password') {
        print('Contraseña incorrecta.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
