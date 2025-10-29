import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Crear cita
  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      await _firestore.collection('citas').add(appointment.toMap());
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  // Obtener todas las citas de un usuario (Stream para tiempo real)
  Stream<List<AppointmentModel>> getAppointmentsStream(String userId) {
    return _firestore
        .collection('citas')
        .where('id_paciente', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              AppointmentModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  // Obtener citas limitadas (para home)
  Stream<List<AppointmentModel>> getLimitedAppointmentsStream(
    String userId, {
    int limit = 3,
  }) {
    return _firestore
        .collection('citas')
        .where('id_paciente', isEqualTo: userId)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              AppointmentModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  // Actualizar cita
  Future<void> updateAppointment(
    String appointmentId,
    AppointmentModel appointment,
  ) async {
    try {
      await _firestore
          .collection('citas')
          .doc(appointmentId)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Error al actualizar cita: $e');
    }
  }

  // Eliminar cita
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('citas').doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Error al eliminar cita: $e');
    }
  }

  // Obtener una cita específica
  Future<AppointmentModel> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore.collection('citas').doc(appointmentId).get();

      if (!doc.exists) {
        throw Exception('Cita no encontrada');
      }

      return AppointmentModel.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      throw Exception('Error al obtener cita: $e');
    }
  }
}
