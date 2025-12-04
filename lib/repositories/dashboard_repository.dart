import '../models/dashboard_stats_model.dart';
import '../models/chart_data_models.dart';
import 'appointment_repository.dart';
import 'doctor_repository.dart';

class DashboardRepository {
  final AppointmentRepository appointmentRepository;
  final DoctorRepository doctorRepository;

  DashboardRepository({
    required this.appointmentRepository,
    required this.doctorRepository,
  });

  // Obtener todas las estadísticas del dashboard
  Future<DashboardStatsModel> getDashboardStats(String doctorId, String especialidad) async {
    try {
      final now = DateTime.now();
      final mesActualInicio = DateTime(now.year, now.month, 1);
      final mesAnteriorInicio = DateTime(now.year, now.month - 1, 1);

      final results = await Future.wait([
        appointmentRepository.getTotalCitasByDoctor(doctorId),
        appointmentRepository.getCitasByEstado(doctorId, 'pendiente'),
        appointmentRepository.getCitasByEstado(doctorId, 'completada'),
        appointmentRepository.getCitasByEstado(doctorId, 'cancelada'),
        appointmentRepository.getPromedioCitasPorDia(doctorId),
        appointmentRepository.getPromedioCitasPorSemana(doctorId),
        appointmentRepository.getPromedioCitasPorMes(doctorId),
        appointmentRepository.getCitasByMonthCount(doctorId, mesActualInicio),
        appointmentRepository.getCitasByMonthCount(doctorId, mesAnteriorInicio),
        doctorRepository.getTotalDoctoresByEspecialidad(especialidad),
        doctorRepository.getRankingByEspecialidad(doctorId, especialidad),
        appointmentRepository.getPacientesNuevos(doctorId, 6),
        appointmentRepository.getCitasByMonth(doctorId, 6),
        appointmentRepository.getCitasByWeek(doctorId, 4),
        appointmentRepository.getTotalPacientesUnicos(doctorId),
        appointmentRepository.getPacientesNuevos(doctorId, 3),
      ]);

      final totalCitas = results[0] as int;
      final citasPendientes = results[1] as int;
      final citasCompletadas = results[2] as int;
      final citasCanceladas = results[3] as int;
      final promedioCitasPorDia = results[4] as double;
      final promedioCitasPorSemana = results[5] as double;
      final promedioCitasPorMes = results[6] as double;
      final citasEsteMes = results[7] as int;
      final citasMesAnterior = results[8] as int;
      final totalDoctoresEspecialidad = results[9] as int;
      final miRanking = results[10] as int;
      final misPacientesNuevos = results[11] as int;
      final citasPorMes = results[12] as List<ChartData>;
      final citasPorSemana = results[13] as List<ChartData>;
      final totalPacientesUnicos = results[14] as int;
      final pacientesNuevos = results[15] as int;

      double porcentajeCambio = 0.0;
      if (citasMesAnterior > 0) {
        porcentajeCambio = ((citasEsteMes - citasMesAnterior) / citasMesAnterior) * 100;
      }

      double promedioEspecialidad = 0.0;
      if (totalDoctoresEspecialidad > 0) {
        promedioEspecialidad = misPacientesNuevos / totalDoctoresEspecialidad.toDouble();
      }

      // Citas por estado para pie chart
      final citasPorEstado = {
        'pendiente': citasPendientes,
        'completada': citasCompletadas,
        'cancelada': citasCanceladas,
      };

      // Obtener datos para comparativa mes actual vs anterior
      ComparativaData? comparativaMesActualVsAnterior;
      if (citasPorMes.length >= 2) {
        final mesActual = citasPorMes[citasPorMes.length - 1];
        final mesAnterior = citasPorMes[citasPorMes.length - 2];
        comparativaMesActualVsAnterior = ComparativaData(
          datos1: [
            ChartData(label: mesAnterior.label, value: mesAnterior.value),
            ChartData(label: mesActual.label, value: mesActual.value),
          ],
          datos2: const [], // solo usamos una serie con dos puntos
          label1: 'Mes Anterior',
          label2: 'Mes Actual',
        );
      }

      // Obtener métricas adicionales
      final rankingEspecialidad = miRanking;

      return DashboardStatsModel(
        totalCitas: totalCitas,
        citasPendientes: citasPendientes,
        citasCompletadas: citasCompletadas,
        citasCanceladas: citasCanceladas,
        promedioCitasPorDia: promedioCitasPorDia,
        promedioCitasPorSemana: promedioCitasPorSemana,
        promedioCitasPorMes: promedioCitasPorMes,
        citasEsteMes: citasEsteMes,
        citasMesAnterior: citasMesAnterior,
        porcentajeCambio: porcentajeCambio,
        miRanking: miRanking,
        totalDoctoresEspecialidad: totalDoctoresEspecialidad,
        misPacientesNuevos: misPacientesNuevos,
        promedioEspecialidad: promedioEspecialidad,
        citasPorMes: citasPorMes,
        citasPorSemana: citasPorSemana,
        citasPorEstado: citasPorEstado,
        comparativaMesActualVsAnterior: comparativaMesActualVsAnterior,
        totalPacientesUnicos: totalPacientesUnicos,
        pacientesNuevos: pacientesNuevos,
        rankingEspecialidad: rankingEspecialidad,
      );
    } catch (e) {
      throw Exception('Error al obtener estadísticas del dashboard: $e');
    }
  }
}
