import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Obtener datos del usuario
  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();

      if (!doc.exists) {
        throw Exception('Usuario no encontrado');
      }

      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  // Crear o actualizar datos del usuario
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('usuarios').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Error al guardar datos del usuario: $e');
    }
  }

  // Stream de datos del usuario (actualización en tiempo real)
  Stream<UserModel> getUserDataStream(String uid) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Usuario no encontrado');
      }
      return UserModel.fromMap(snapshot.data()!);
    });
  }

  // Verificar si el usuario existe
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Obtener el rol del usuario (verifica si existe en la colección doctores)
  Future<String> getUserRole(String uid) async {
    try {
      final doctorDoc = await _firestore.collection('doctores').doc(uid).get();

      if (doctorDoc.exists) {
        return 'medico';
      } else {
        return 'paciente';
      }
    } catch (e) {
      throw Exception('Error al obtener rol del usuario: $e');
    }
  }

  // Obtener datos completos del usuario incluyendo rol
  Future<Map<String, dynamic>> getUserWithRole(String uid) async {
    try {
      // Obtener datos básicos del usuario
      final userDoc = await _firestore.collection('usuarios').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }

      Map<String, dynamic> userData = userDoc.data()!;

      // Verificar si es médico
      final doctorDoc = await _firestore.collection('doctores').doc(uid).get();

      if (doctorDoc.exists) {
        // Es médico, agregar datos de doctor
        userData['role'] = 'medico';
        userData.addAll(doctorDoc.data()!);
      } else {
        // Es paciente
        userData['role'] = 'paciente';
      }

      return userData;
    } catch (e) {
      throw Exception('Error al obtener datos completos del usuario: $e');
    }
  }
}
