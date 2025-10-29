import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Iniciar sesión
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No se encontró ningún usuario con ese correo');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta');
      } else if (e.code == 'invalid-email') {
        throw Exception('Correo electrónico inválido');
      } else {
        throw Exception('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Verificar si hay usuario logueado
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Obtener UID del usuario actual
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Obtener email del usuario actual
  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }
}
