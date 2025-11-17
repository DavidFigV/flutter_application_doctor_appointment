import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../models/chart_data_models.dart';

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

  // ==================== MÉTODOS ANALÍTICOS PARA DASHBOARD ====================

  // Stream de citas por doctor
  Stream<List<AppointmentModel>> getAppointmentsByDoctorStream(String doctorId) {
    return _firestore
        .collection('citas')
        .where('id_doctor', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  // Total de citas por doctor
  Future<int> getTotalCitasByDoctor(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar citas: $e');
    }
  }

  // Citas por estado
  Future<int> getCitasByEstado(String doctorId, String estado) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .where('estado', isEqualTo: estado)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar citas por estado: $e');
    }
  }

  // Stream de citas agrupadas por estado
  Stream<Map<String, int>> getCitasGroupedByEstado(String doctorId) {
    return _firestore
        .collection('citas')
        .where('id_doctor', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      Map<String, int> result = {
        'pendiente': 0,
        'completada': 0,
        'cancelada': 0,
      };

      for (var doc in snapshot.docs) {
        final estado = doc.data()['estado'] ?? 'pendiente';
        result[estado] = (result[estado] ?? 0) + 1;
      }

      return result;
    });
  }

  // Citas por mes (últimos N meses)
  Future<List<ChartData>> getCitasByMonth(String doctorId, int months) async {
    try {
      final now = DateTime.now();
      final List<ChartData> result = [];

      for (int i = months - 1; i >= 0; i--) {
        final targetMonth = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(now.year, now.month - i + 1, 1);

        final snapshot = await _firestore
            .collection('citas')
            .where('id_doctor', isEqualTo: doctorId)
            .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(targetMonth))
            .where('fecha', isLessThan: Timestamp.fromDate(nextMonth))
            .get();

        result.add(ChartData(
          label: DateFormat('MMM', 'es').format(targetMonth),
          value: snapshot.docs.length.toDouble(),
          date: targetMonth,
        ));
      }

      return result;
    } catch (e) {
      throw Exception('Error al obtener citas por mes: $e');
    }
  }

  // Citas por semana (últimas N semanas)
  Future<List<ChartData>> getCitasByWeek(String doctorId, int weeks) async {
    try {
      final now = DateTime.now();
      final List<ChartData> result = [];

      for (int i = weeks - 1; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i * 7));
        final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));

        final snapshot = await _firestore
            .collection('citas')
            .where('id_doctor', isEqualTo: doctorId)
            .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
            .where('fecha', isLessThan: Timestamp.fromDate(weekEnd))
            .get();

        result.add(ChartData(
          label: 'S${weeks - i}',
          value: snapshot.docs.length.toDouble(),
          date: weekStart,
        ));
      }

      return result;
    } catch (e) {
      throw Exception('Error al obtener citas por semana: $e');
    }
  }

  // Citas de un mes específico
  Future<int> getCitasByMonthCount(String doctorId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('fecha', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar citas del mes: $e');
    }
  }

  // Promedio de citas por día
  Future<double> getPromedioCitasPorDia(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      // Obtener fechas únicas
      final Set<String> diasUnicos = {};
      for (var doc in snapshot.docs) {
        final fecha = (doc.data()['fecha'] as Timestamp).toDate();
        diasUnicos.add(DateFormat('yyyy-MM-dd').format(fecha));
      }

      if (diasUnicos.isEmpty) return 0.0;

      return snapshot.docs.length / diasUnicos.length;
    } catch (e) {
      throw Exception('Error al calcular promedio por día: $e');
    }
  }

  // Promedio de citas por semana
  Future<double> getPromedioCitasPorSemana(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      // Calcular primera y última cita
      DateTime? primeraFecha;
      DateTime? ultimaFecha;

      for (var doc in snapshot.docs) {
        final fecha = (doc.data()['fecha'] as Timestamp).toDate();
        if (primeraFecha == null || fecha.isBefore(primeraFecha)) {
          primeraFecha = fecha;
        }
        if (ultimaFecha == null || fecha.isAfter(ultimaFecha)) {
          ultimaFecha = fecha;
        }
      }

      if (primeraFecha == null || ultimaFecha == null) return 0.0;

      final diferenciaDias = ultimaFecha.difference(primeraFecha).inDays;
      final semanas = (diferenciaDias / 7).ceil();

      if (semanas == 0) return snapshot.docs.length.toDouble();

      return snapshot.docs.length / semanas;
    } catch (e) {
      throw Exception('Error al calcular promedio por semana: $e');
    }
  }

  // Promedio de citas por mes
  Future<double> getPromedioCitasPorMes(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      // Obtener meses únicos
      final Set<String> mesesUnicos = {};
      for (var doc in snapshot.docs) {
        final fecha = (doc.data()['fecha'] as Timestamp).toDate();
        mesesUnicos.add('${fecha.year}-${fecha.month}');
      }

      if (mesesUnicos.isEmpty) return 0.0;

      return snapshot.docs.length / mesesUnicos.length;
    } catch (e) {
      throw Exception('Error al calcular promedio por mes: $e');
    }
  }

  // Total de pacientes únicos
  Future<int> getTotalPacientesUnicos(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .get();

      final Set<String> pacientesUnicos = {};
      for (var doc in snapshot.docs) {
        pacientesUnicos.add(doc.data()['id_paciente']);
      }

      return pacientesUnicos.length;
    } catch (e) {
      throw Exception('Error al contar pacientes únicos: $e');
    }
  }

  // Pacientes nuevos en los últimos N meses
  Future<int> getPacientesNuevos(String doctorId, int months) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - months, 1);

      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .where('es_primera_cita', isEqualTo: true)
          .where('fecha_creacion', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar pacientes nuevos: $e');
    }
  }

  // Citas de hoy para un doctor
  Future<List<AppointmentModel>> getCitasDeHoy(String doctorId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .where('fecha', isLessThan: Timestamp.fromDate(tomorrow))
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener citas de hoy: $e');
    }
  }

  // Total de citas entre un doctor y un paciente específico (para calcular esPrimeraCita)
  Future<int> getTotalCitasByDoctorAndPaciente(
    String doctorId,
    String pacienteId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('citas')
          .where('id_doctor', isEqualTo: doctorId)
          .where('id_paciente', isEqualTo: pacienteId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar citas entre doctor y paciente: $e');
    }
  }
}
