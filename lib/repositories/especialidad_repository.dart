import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/especialidad_model.dart';

class EspecialidadRepository {
  final FirebaseFirestore _firestore;

  EspecialidadRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream de especialidades activas
  Stream<List<EspecialidadModel>> getEspecialidadesActivas() {
    return _firestore
        .collection('especialidades')
        .where('activa', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EspecialidadModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener una especialidad específica
  Future<EspecialidadModel?> getEspecialidad(String nombre) async {
    try {
      final doc = await _firestore.collection('especialidades').doc(nombre).get();

      if (!doc.exists) {
        return null;
      }

      return EspecialidadModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error al obtener especialidad: $e');
    }
  }

  // Incrementar contador de doctores
  Future<void> incrementTotalDoctores(String especialidad) async {
    try {
      final doc = _firestore.collection('especialidades').doc(especialidad);

      // Verificar si el documento existe
      final snapshot = await doc.get();

      if (snapshot.exists) {
        // Si existe, incrementar el contador
        await doc.update({
          'total_doctores': FieldValue.increment(1),
        });
      } else {
        // Si no existe, crear el documento con valores iniciales
        await doc.set({
          'nombre': especialidad,
          'total_doctores': 1,
          'activa': true,
          'descripcion': '',
        });
      }
    } catch (e) {
      throw Exception('Error al incrementar contador: $e');
    }
  }

  // Decrementar contador de doctores
  Future<void> decrementTotalDoctores(String especialidad) async {
    try {
      final doc = _firestore.collection('especialidades').doc(especialidad);

      // Verificar si el documento existe antes de decrementar
      final snapshot = await doc.get();

      if (snapshot.exists) {
        await doc.update({
          'total_doctores': FieldValue.increment(-1),
        });
      }
      // Si no existe, no hacemos nada (no podemos decrementar algo que no existe)
    } catch (e) {
      throw Exception('Error al decrementar contador: $e');
    }
  }

  // Obtener todas las especialidades (incluyendo inactivas)
  Future<List<EspecialidadModel>> getAllEspecialidades() async {
    try {
      final snapshot = await _firestore.collection('especialidades').get();
      return snapshot.docs
          .map((doc) => EspecialidadModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener especialidades: $e');
    }
  }
}
