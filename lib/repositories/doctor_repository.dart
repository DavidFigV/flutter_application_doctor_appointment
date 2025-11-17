import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;

  DoctorRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Obtener datos del doctor
  Future<DoctorModel?> getDoctorData(String uid) async {
    try {
      final doc = await _firestore.collection('doctores').doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      return DoctorModel.fromMap(doc.data()!, uid);
    } catch (e) {
      throw Exception('Error al obtener datos del doctor: $e');
    }
  }

  // Crear o actualizar datos del doctor
  Future<void> saveDoctorData(DoctorModel doctor) async {
    try {
      await _firestore.collection('doctores').doc(doctor.uid).set(doctor.toMap());
    } catch (e) {
      throw Exception('Error al guardar datos del doctor: $e');
    }
  }

  // Stream de doctores por especialidad
  Stream<List<DoctorModel>> getDoctoresByEspecialidad(String especialidad) {
    return _firestore
        .collection('doctores')
        .where('especialidad', isEqualTo: especialidad)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Verificar si es doctor activo
  Future<bool> isDoctorActive(String uid) async {
    try {
      final doc = await _firestore.collection('doctores').doc(uid).get();
      if (!doc.exists) return false;
      return doc.data()?['activo'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Obtener total de doctores por especialidad
  Future<int> getTotalDoctoresByEspecialidad(String especialidad) async {
    try {
      final snapshot = await _firestore
          .collection('doctores')
          .where('especialidad', isEqualTo: especialidad)
          .where('activo', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar doctores: $e');
    }
  }

  // Obtener ranking del doctor en su especialidad
  Future<int> getRankingByEspecialidad(String doctorId, String especialidad) async {
    try {
      // Obtener todos los doctores de la misma especialidad
      final doctoresSnapshot = await _firestore
          .collection('doctores')
          .where('especialidad', isEqualTo: especialidad)
          .where('activo', isEqualTo: true)
          .get();

      if (doctoresSnapshot.docs.isEmpty) return 0;

      // Obtener total de citas de cada doctor
      final List<Map<String, dynamic>> doctoresConCitas = [];

      for (var doctorDoc in doctoresSnapshot.docs) {
        final citasSnapshot = await _firestore
            .collection('citas')
            .where('id_doctor', isEqualTo: doctorDoc.id)
            .get();

        doctoresConCitas.add({
          'uid': doctorDoc.id,
          'totalCitas': citasSnapshot.docs.length,
        });
      }

      // Ordenar por total de citas (descendente)
      doctoresConCitas.sort((a, b) => (b['totalCitas'] as int).compareTo(a['totalCitas'] as int));

      // Encontrar posición del doctor actual
      final index = doctoresConCitas.indexWhere((doc) => doc['uid'] == doctorId);
      return index >= 0 ? index + 1 : 0;
    } catch (e) {
      throw Exception('Error al calcular ranking: $e');
    }
  }

  // Verificar si existe un doctor
  Future<bool> doctorExists(String uid) async {
    try {
      final doc = await _firestore.collection('doctores').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
